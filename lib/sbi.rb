require 'mechanize'
require 'loggable'

class Sbi
  USER_AGENT_MOBILE = 'SoftBank/1.0/912SH/SHJ001/SN123456789012345 Browser/NetFront/3.4'
  URI_BASE = 'https://mobile.sbisec.co.jp'

  include Gena::Loggable

  def initialize
    @pit = Pit.get 'sbi', :require => {
      'username' => 'mirakui',
      'password' => ''
    }
    @agent = WWW::Mechanize.new
    @agent.user_agent = USER_AGENT_MOBILE
    #@agent.logger = logger
    login
  end

  def login
    get '/'
    page.link_with(:href => /loginUser/).click
    page.form_with(:name => nil) do |form|
      form.field_with(:name => 'username').value = @pit['username']
      form.field_with(:name => 'password').value = @pit['password']
      form.submit
    end
    page.form_with(:name => nil) do |form|
      form.field_with(:name=>'product_group').value = 'sbi_fx_alpha'
      form.submit
    end
  end

  def logout?
    page.uri =~ /logout\.aspx/
  end

  def pboard
    if page.uri =~ /pboard/
      pboard_reload
    else
      go_pboard
    end

    meigaras = page.links_with(:href => /meigaraId/).map {|mm| mm.href =~ /meigaraId=(.*?)&/; $1 }
    prices   = {}
    (page / 'b').each_with_index do |b, i|
      price_pair = b.text.strip.split('-')
      prices[meigaras[i]] = {:bid => price_pair[0], :ask => price_pair[1]}
    end
    prices
  end

  def go_pboard
    page.link_with(:href => /pboard/).click
  end


  def require_page(page)

  end

  class UnexpectedPage < StandardError
  end

  class Page
    def initialize(agent)
      @agent = agent
    end

    def get(query)
      @agent.get URI_BASE + query
    rescue => e
      logger.error [e.to_s, e.backtrace].flatten.join("/n")
    end

    def page
      @agent.page
    end

    def required_self
      if self.now?
        self
      else
        self.go
      end
    end

    def go
      raise "not implemented"
    end

    def now?(page_class)
      page_class.now?(page)
    end

    def self.func_name(prefix, sym)
      "__#{prefix.to_s}_#{sym.to_s}"
    end

    def define(prefix, func)
      define_method(func_name(prefix, sym), func)
    end
    
    def call(prefix, syms)
      if syms.empty?
        return nil
      elsif syms.length == 1
        return send(prefix.to_s+syms.first.to_s)
      else
        return syms.map{|sym| required(sym)}
      end
    end

    def self.add_required(sym, &func)
      define(:required, func)
    end

    def self.add_go(sym, &func)
      define(:go, func)
    end

    def self.add_now?(sym, &func)
      define(:now?, func)
    end

    def required(*syms)
      call(:requierd, syms)
    end

    def go(*syms)
      call(:go, syms)
    end

    def now?(*syms)
      call(:now?, syms)
    end

    def retry_on_logout
      yield
      if now?(:logout)
        login
        yield
      end
    end

    def required(sym)
      go(sym) unless now?(sym)
    end

    add_page(:pboard,
      :now? => proc {
        page.uri =~ %r(pboard)
      },
      :go => proc {
        retry_on_logout do
          if now?(:pboard)
            page.form_with(:name => 'CancelSelect').click_button
            #bug
          else
            required(:fx_index)
            page.link_with(:href => /pboard/).click
          end
        end
      },
    )

    add_page(:login,      
    )

    add_page(:login) do
      :now? => proc {
        page.uri =~ %r(loginUser)
      },
      :go => proc {
        get '/'
        page.link_with(:href => /loginUser/).click
      }
    end

    add_go(:pboard) do
    end

    add_go(:fx_index) do
      required(:index)
      page.form_with(:name => nil) do |form|
        form.field_with(:name=>'product_group').value = 'sbi_fx_alpha'
        form.submit
      end
    end

    add_now?(:pboard) do
      page.uri =~ %r(pboard)
    end

    add_now?(:logout) do
      page.uri =~ %r(logout\.aspx)
    end

    add_now?(:index) do
      page.uri =~ %r(loginUserCheck\.do|menu\.do|login\.do)
    end

    add_now?(:fx_index) do
      page.uri =~ %r(forex/trade/mobile/client/index\.aspx)
    end
  end

end

__END__
sbi = Sbi.new
sbi.login


