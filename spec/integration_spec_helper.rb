require 'capybara/rspec'
# require 'rack_session_access/capybara'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(no-sandbox headless disable-gpu window-size=1920x1080) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

Capybara.default_driver = RUBY_PLATFORM =~ /darwin/ ? :selenium : :headless_chrome
# Capybara.default_driver = :headless_chrome

Capybara.app = Rack::Builder.parse_file('config.ru').first
# Capybara.default_max_wait_time = 5

Capybara.save_path = File.absolute_path(ROOT_DIR + '/spec/support/capybara')

require 'capybara-screenshot/rspec'
Capybara::Screenshot.autosave_on_failure = false


Capybara.modify_selector(:link) do
  xpath(:title, :alt) do |locator, options={}|
    xpath = XPath.descendant(:a)
    xpath = if options.fetch(:href, true).nil?
      xpath[~XPath.attr(:href)]
    else
      xpath#[XPath.attr(:href)]
    end
    unless locator.nil?
      locator = locator.to_s
      matchers = XPath.attr(:id).equals(locator).or(
                 XPath.string.n.is(locator)).or(
                 XPath.attr(:title).is(locator)).or(
                 XPath.descendant(:img)[XPath.attr(:alt).is(locator)])
      matchers = matchers.or XPath.attr(:'aria-label').is(locator) if options[:enable_aria_label]
      xpath = xpath[matchers]
    end
    xpath = [:title].inject(xpath) { |memo, ef| memo[find_by_attr(ef, options[ef])] }
    xpath = xpath[XPath.descendant(:img)[XPath.attr(:alt).equals(options[:alt])]] if options[:alt]
    xpath
  end
end

RSpec::Matchers.define :have_task do |expected|
  match do |page|
    find_task_element expected
  end
end

RSpec::Matchers.define :have_search_result do |name, opts = {}|
  match do |page|
    klass = '.result-row'
    klass += '.selected-result' if opts[:selected]
    
    has_selector? klass, text: name
  end
end

RSpec::Matchers.define :have_tag do |expected|
  match do |page|
    find_tag_element expected
  end
end

RSpec::Matchers.define :have_no_modal do
  match do |page|
    page.has_selector? 'body:not(.modal-open)'
  end
end

module CapybaraHelper
  def javascript_driver?
    %i[selenium poltergeist].include? Capybara.current_driver
  end
  
  def go_home
    visit '/#/tasks'
  end
  
  def current_fragment
    URI.parse(page.current_url).fragment
  end
  
  def score
    find('#score').text.to_i
  end
  
  def open_search
    page.find('body').send_keys :space
  end

  def add_new_task(name: 'test', description: 'lol', value: 1, recurring: true, tag: 'mytag')
    open_new_task_form
    fill_in_task_form(name: name, description: description, value: value, recurring: recurring, tag: tag)
    
    click_on 'Save'
  end
  
  def open_new_task_form
    within('header') {click_on 'Add new task'}
  end
  
  def edit_task(original: {}, name: 'test', description: 'lol', value: 1, recurring: true)
    open_edit_task_form(original)
    fill_in_task_form(name: name, description: description, value: value, recurring: recurring)
    
    click_on 'Save'
  end
  
  def open_edit_task_form(original)
    card = find_task_element(original)

    within(card) {click_on 'Edit'}
  end
  
  def fill_in_task_form(name: 'test', description: 'lol', value: 1, recurring: true, tag: 'mytag')
    fill_in 'Name', with: name
    fill_in 'Value', with: value
    find('input[name=recurring]').set recurring
    
    input = find('.select-tags').find('input')
    input.set(tag)
    input.native.send_keys(:return)
  end
  
  def find_task_element(query)
    raise ArgumentError, 'must specify query' if query.blank?
    card_selector = '.task-cards .card'
    
    page.has_selector? card_selector
    cards = page.find_all card_selector
    
    card = cards.find do |card|
      # binding.pry; 
      if query[:name]
        next unless card.has_selector? ".card-title", text: query[:name]
      end
      
      if query[:tag]
        next unless card.has_selector? "span.tag", text: query[:tag]
      end
      
      true
    end

    unless card
      puts page.html
      raise 'didnt find task'
    end

    card
  end
  
  def edit_tag(original: {}, name: 'test', goal: 100, show_meter: true)
    open_edit_tag_form(original)
    fill_in_tag_form(name: name, goal: goal, show_meter: show_meter)
    
    click_on 'Save'
  end
  
  def open_edit_tag_form(original)
    find_tag_element(original).click
  end
  
  def fill_in_tag_form(name: 'test', goal: 100, show_meter: true)
    fill_in 'Name', with: name
    fill_in 'Goal (per week)', with: goal
    find_field('show_meter').set show_meter
  end
  
  def find_tag_element(query)
    raise ArgumentError, 'must specify query' if query.blank?
    card_selector = 'span.tag'
    
    # page.has_selector? card_selector
    element = page.find card_selector, text: query[:name]

    unless element
      puts page.html
      raise 'didnt find tag'
    end

    element
  end
end

class DriverJSError < StandardError; end

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include CapybaraHelper

  config.before(:suite) do
    FileUtils.rm Dir.glob(Capybara.save_path + '/*')
  end
  
  config.after(:each, type: :integration) do |example|
    sleep 0.05
    
    if example.exception && ENV['SCREENSHOT']
      Capybara::Screenshot.screenshot_and_open_image
    end
    
    errors = page.driver.browser.manage.logs.get(:browser).
      select {|e| e.level == "SEVERE" && e.message.present? }.
      map(&:message)
    
    errors.reject! {|e| Array(example.metadata[:ignored_js_errors]).any? {|ie| e.include? ie}}
    
    if errors.present?
      raise DriverJSError, errors.join("\n\n")
    end
  end
end
