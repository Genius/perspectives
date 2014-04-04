(function($, window, document, undefined) {
  var renderTemplateData = function(data) {
    var view = {}

    for(key in data) {
      if (!data.hasOwnProperty(key)) continue

      if ($.isArray(data[key])) {
        view[key] = $.map(data[key], function(value) {
          var new_value = $.extend(!!'deep_copy', {}, value)

          if (value['_template_key']) {
            new_value['to_s'] = new_value['render'] = renderTemplateData(value)
          }

          return new_value
        })
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

  var PerspectivesVersion = function() {
    return $('meta').filter(function() {
      var name = $(this).attr('http-equiv')
      return name && name.toUpperCase() === 'X-PERSPECTIVEs-VERSION'
    }).attr('content')
  }

  var renderPerspectivesResponse = function(href, container, json, status, xhr) {
    var $container = $(container)
    console.time(' perspectives rendering')

    var version = PerspectivesVersion() || ''
    if (version.length && version !== xhr.getResponseHeader('X-Perspectives-Version')) {
      locationReplace(href)
      return false
    }

    var $rendered = $(renderTemplateData(json))
    var $perspectives = $container

    if ($perspectives.hasClass('transitions')) {
      var oldSegments = window.location.href.split('/'),
          newSegments = href.split('/')

      var transposition = 'transposed-' + (oldSegments.length < newSegments.length ? 'right' : 'left')

      var $content = $('<div>', {'class': 'content ' + transposition })
                      .append($rendered)

      $container.html($('<div>', {'class': 'wrapper'}).append($content))

      setTimeout(function() {
        $container
          .find('.content')
          .addClass('loaded')
          .removeClass(transposition)
      }, 0)
    } else {
      $perspectives.html($rendered)
    }

    $(document).trigger('perspectives:reload')

    console.timeEnd(' perspectives rendering')
  }

  var handlePerspectivesClick = function(container) {
    var href = this.href

    $.getJSON(href, function() {
      var args = Array.prototype.slice.call(arguments)
      args.unshift(href, container)

      renderPerspectivesResponse.apply(this, args)
      window.history.pushState({container: container}, href, href)
    })

    return false
  }

  $(window).on('popstate.perspectives', function(event) {
    var originalEvent = event.originalEvent
    if(originalEvent && originalEvent.state && originalEvent.state.container) {
      $.getJSON(window.location.href, renderPerspectivesResponse.bind(null, window.location.href, originalEvent.state.container))
    }
  })

  $.fn.perspectives = function(selector, container) {
    $(this).on('click', selector, function() {
      return handlePerspectivesClick.bind(this)(container)
    })
  }
})(jQuery, window, document)
