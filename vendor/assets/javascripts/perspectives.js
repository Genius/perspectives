(function($, window, document, undefined) {
  var renderTemplateData = function(data) {
    var view = {}

    for(var key in data) {
      if (!data.hasOwnProperty(key)) continue

      if ($.isArray(data[key])) {
        view[key] = $.map(data[key], function(value) {
          var new_value = $.extend(!!'deep_copy', {}, value)

          if (value['_template_key']) {
            new_value['to_s'] = new_value['to_html'] = renderTemplateData(value)
          }

          return new_value
        })

        view[key].toString = function() { return $.map(this, function(value) { return value.to_html }).join('') }
      } else if (data[key] && typeof data[key] === 'object' && data[key]['_template_key']) {
        view[key] = renderTemplateData(data[key])
      } else {
        view[key] = data[key]
      }
    }

    view['to_s'] = function() { toString() }

    return LP[data._template_key](view)
  }

  // pretty much ganked from pjax...
  var locationReplace = function(url) {
    window.history.replaceState(null, "", "#")
    window.location.replace(url)
  }

  var perspectivesVersion = function() {
    return $('meta').filter(function() {
      var name = $(this).attr('http-equiv')
      return name && name.toUpperCase() === 'X-PERSPECTIVES-VERSION'
    }).attr('content')
  }

  var renderPerspectivesResponse = function(options) {
    var $container = $(options.container)
    console.time('perspectives rendering')

    var version = perspectivesVersion() || ''
    if (version.length && version !== xhr.getResponseHeader('X-Perspectives-Version')) {
      locationReplace(options.href)
      return false
    }

    var $rendered = $(renderTemplateData(options.json))

    $container.html($rendered)

    $(document).trigger('perspectives:load', options.xhr)

    console.timeEnd('perspectives rendering')
  }

  var perspectivesContainer = function($element, defaultContainer) {
    return $($element.attr('data-perspectives-target')).length ? $element.attr('data-perspectives-target') : defaultContainer
  }

  var handlePerspectivesClick = function(container) {
    var $this = $(this)
    var href = this.href
    var replaceContainer = perspectivesContainer($this, container)

    $.ajax({
      method: 'GET',
      url:href,
      dataType: 'json',
      headers: { 'x-perspectives-full-page': !!$this.attr('data-perspectives-full-page') }
    }).success(function(json, status, xhr) {
      $this.trigger('perspectives:response', [renderPerspectivesResponse, {
        json: json,
        status: status,
        xhr: xhr,
        href: href,
        container: replaceContainer
      }])

      window.history.pushState({container: container}, href, href)
    })

    return false
  }

  $(document).on('perspectives:response', function(e, defaultRender, options) { defaultRender(options) })

  $(document).on('ajax:success', function(event, data, status, xhr) {
    if (!xhr.getResponseHeader('Content-Type').match(/json/i)) return

    var $form = $(event.target),
        $globalContainer = $('[data-global-perspectives-target]'),
        href = $form.attr('action'),
        container = perspectivesContainer($form, $globalContainer)

    $form.trigger('perspectives:response', [renderPerspectivesResponse, {
      json: data,
      status: status,
      xhr: xhr,
      href: href,
      container: container
    }])

    window.history.pushState({container: $globalContainer.selector}, href, href)

    return false
  })

  $(window).on('popstate.perspectives', function(event) {
    var originalEvent = event.originalEvent
    if(originalEvent && originalEvent.state && originalEvent.state.container) {
      $.ajax({
        method: 'GET',
        url: window.location.href,
        dataType: 'json',
        headers: { 'x-perspectives-full-page': true }
      }).success(function(json, status, xhr) {
        renderPerspectivesResponse({
          json: json,
          status: status,
          xhr: xhr,
          href: window.location.href,
          container: originalEvent.state.container
        })
      })
    }
  })

  $.fn.perspectives = function(selector, container) {
    $(container).attr('data-global-perspectives-target', true)

    $(this).on('click', selector, function() {
      return handlePerspectivesClick.bind(this)(container)
    })
  }

  LP.renderTemplateData = LP.render = renderTemplateData
})(jQuery, window, document)
