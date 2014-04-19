(function($, window, document, undefined) {
  window.Perspectives = window.Perspectives || {}

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

    return Perspectives.views[data._template_key](view)
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

  var renderResponse = function(options) {
    var $globalContainer = globalPerspectivesContainer(),
        $container = $(options.container).length ? $(options.container) : $globalContainer
    console.time('perspectives rendering')

    var version = perspectivesVersion() || ''
    if (version.length && version !== xhr.getResponseHeader('X-Perspectives-Version')) {
      locationReplace(options.href)
      return false
    }

    var $rendered = $(renderTemplateData(options.json))

    $container.html($rendered)

    if (!options.noPushState) {
      window.history.pushState({container: globalPerspectivesContainer().selector}, options.href, options.href)
    }

    $(document).trigger('perspectives:load', options.xhr)

    console.timeEnd('perspectives rendering')
  }

  var globalPerspectivesContainer = function() {
    return $('[data-global-perspectives-target]')
  }

  var handlePerspectivesClick = function(container) {
    var $this = $(this)

    navigate({
      href: this.href,
      container: $this.attr('data-perspectives-target'),
      fullPage: !!$this.attr('data-perspectives-full-page'),
      element: $this
    })

    return false
  }

  var navigate = function(options) {
    var $element = $(options.element || document)

    $.ajax({
      method: 'GET',
      url: options.href,
      dataType: 'json',
      headers: { 'x-perspectives-full-page': !!options.fullPage }
    }).success(function(json, status, xhr) {
      $element.trigger('perspectives:response', {
        json: json,
        status: status,
        xhr: xhr,
        href: options.href,
        container: options.container,
        noPushState: options.noPushState
      })
    })
  }

  $(document).on('perspectives:response', function(e, options) { renderResponse(options) })

  $(document).on('ajax:success', function(event, data, status, xhr) {
    if (!xhr.getResponseHeader('Content-Type').match(/json/i)) return

    var $form = $(event.target),
        $globalContainer = globalPerspectivesContainer(),
        href = $form.attr('action'),
        container = $form.attr('data-perspectives-target')

    $form.trigger('perspectives:response', {
      json: data,
      status: status,
      xhr: xhr,
      href: href,
      container: container
    })

    return false
  })

  $(window).on('popstate.perspectives', function(event) {
    var originalEvent = event.originalEvent
    if(originalEvent && originalEvent.state && originalEvent.state.container) {
      navigate({
        href: window.location.href,
        container: originalEvent.state.container,
        fullPage: true,
        noPushState: true
      })
    }
  })

  $.fn.perspectives = function(selector, container) {
    $(container).attr('data-global-perspectives-target', true)

    $(this).on('click', selector, function() {
      return handlePerspectivesClick.bind(this)(container)
    })
  }

  Perspectives.renderTemplateData = Perspectives.render = renderTemplateData
  Perspectives.navigate = navigate
  Perspectives.renderResponse = renderResponse
})(jQuery, window, document)
