require "ferrum_pdf/version"
require "ferrum_pdf/railtie"
require "ferrum"

module FerrumPdf
  DEFAULT_HEADER_TEMPLATE = "<div class='date text left'></div><div class='title text center'></div>"
  DEFAULT_FOOTER_TEMPLATE = <<~HTML
    <div class='url text left grow'></div>
    <div class='text right'><span class='pageNumber'></span>/<span class='totalPages'></span></div>
  HTML

  autoload :Controller, "ferrum_pdf/controller"
  autoload :HTMLPreprocessor, "ferrum_pdf/html_preprocessor"

  mattr_accessor :include_controller_module
  @@include_controller_module = true

  class << self
    def browser(**options)
      @browser ||= Ferrum::Browser.new(options)
    end

    def render_pdf(html: nil, url: nil, host: nil, protocol: nil, authorize: nil, pdf_options: {})
      sleep(2)
      render(host: host, protocol: protocol, html: html, url: url, authorize: authorize) do |page|
        page.pdf(**pdf_options.with_defaults(encoding: :binary))
      end
    end

    def render_screenshot(html: nil, url: nil, host: nil, protocol: nil, authorize: nil, screenshot_options: {})
      render(host: host, protocol: protocol, html: html, url: url, authorize: authorize) do |page|
        page.screenshot(**screenshot_options.with_defaults(encoding: :binary, full: true))
      end
    end

    def render(host:, protocol:, html: nil, url: nil, authorize: nil)
      browser(headless: false).create_page do |page|
        page.network.authorize(user: authorize[:user], password: authorize[:password]) { |req| req.continue } if authorize
        sleep(2)
        if html
          page.content = html
          page.network.wait_for_idle
          sleep(7)
        else
          page.go_to(url)
          sleep(7)
        end
sleep(7)
        # page.evaluate <<~JS
        # Object.keys(Chartkick.charts).forEach(function (key) {
              # Chartkick.charts[key].redraw();
          # });
        # JS
        sleep(7)
        yield page
      end
    rescue Ferrum::DeadBrowserError
      retry
    end
  end
end
