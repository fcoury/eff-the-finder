require 'delegate'

class F::Result < DelegateClass(Array)

  class PageError < StandardError
  end

  attr_accessor :header
  attr_reader :page

  class Item

    attr_reader :name, :url

    def initialize(name, url)
      @name, @url = name, url
    end

    def to_s
      name
    end

    alias inspect to_s

  end

  def self.url_from_anchor_attr(*names)
    names.each do |name|

      define_method "#{name}=" do |a|
        instance_variable_set "@#{name}", a.kind_of?(String) ? a : a[0]['href'] unless a.nil? || a.empty?
      end

      define_method name do
        instance_variable_get "@#{name}"
      end

    end
  end

  url_from_anchor_attr :next_url, :previous_url

  def initialize(finder, page)
    @finder, @page = finder, page
    @items = []
    super(@items)
  end

  def header
    @header ||= "Results for #{@finder.args.join(' ')}\n"
  end

  def items=(items)
    @items.replace(items.map { |a| make_item(a) })
  end

  def <<(item)
    @items << make_item(*item)
  end

  def make_item(*args)
    if args.size == 1 && args[0].respond_to?(:text) && args[0].respond_to?(:[])
      text, url = args[0].text, args[0]['href']
    else
      text, url = *args
    end

    Item.new(text, @finder.absolutize_uri(url))
  end

  def page(p)
    attr = "#{p}_url"
    raise PageError if !respond_to?(attr) || send(attr).nil?
    @finder.find_by_url(send(attr))
  end

  def next_page
    page(:next)
  end

  def previous_page
    page(:previous)
  end

end
