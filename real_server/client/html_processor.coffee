class window.HTMLProcessor

    processHTML: (html) ->
      html = processImages(html)
      html = processScripts(html)
      html = processStyleSheets(html)
      html = processLinks(html)
      return html
      
    processImages: (html) ->
      
      return html
