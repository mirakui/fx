require 'mechanize'
require 'loggable'
require 'method_addable'
require 'market'

class Sbi < Market
  USER_AGENT_MOBILE = 'SoftBank/1.0/912SH/SHJ001/SN123456789012345 Browser/NetFront/3.4'
  URI_BASE = 'https://mobile.sbisec.co.jp'

  def initialize
    @transit = SbiTransit.new
  end

  def prices
    @transit.prices
  end

  def reload_prices
    @transit.reload_prices
  end

  class SbiTransit < Gena::MethodAddable

    attr_reader :prices_buffer

    def initialize
      @pit = Pit.get 'sbi', :require => {
        'username' => 'mirakui',
        'password' => ''
      }
      @agent = WWW::Mechanize.new
      @agent.user_agent = USER_AGENT_MOBILE
      @prices_buffer = nil
      #@agent.logger = logger
    end
    
    def prices
      @prices_buffer || reload_prices
    end

    def reload_prices
      parse(:pboard)
    end

    def page
      @agent.page
    end

    def get(query)
      @agent.get URI_BASE + query
    rescue => e
      logger.error [e.to_s, e.backtrace].flatten.join("/n")
    end

    def self.location(sym, *procs)
      self.add(sym, *procs)
    end

    location :login,
      :now? => proc {
        now? %r(loginUser)
      },
      :submit => proc {
        get '/'
        page.link_with(:href => /loginUser/).click
        page.form_with(:name => nil) do |form|
          form.field_with(:name => 'username').value = @pit['username']
          form.field_with(:name => 'password').value = @pit['password']
          form.submit
        end
      }

    location :logout,
      :now? => proc {
        now? %r(logout\.aspx)
      }

    location :fx_index,
      :now? => proc {
        now? %r(forex/trade/mobile/client/index\.aspx)
      },
      :go => proc {
        submit(:login)
        page.form_with(:name => nil) do |form|
          form.field_with(:name=>'product_group').value = 'sbi_fx_alpha'
          form.submit
        end
      }

    location :pboard,
      :now? => proc {
        now? %r(pboard)
      },
      :go => proc {
        retry_on(:logout) do
          if now? :pboard
            page.form_with(:name => 'CancelSelect').click_button
          else
            required :fx_index 
            page.link_with(:href => /pboard/).click
          end
        end
      },
      :parse => proc {
        required :pboard
        meigaras = page.links_with(:href => /meigaraId/).map {|mm| mm.href =~ /meigaraId=(.*?)&/; $1 }
        prices   = {}
        (page / 'b').each_with_index do |b, i|
          price_pair = b.text.strip.split('-')
          prices[meigaras[i]] = {:bid => price_pair[0].to_f, :ask => price_pair[1].to_f}
        end
        @prices_buffer = prices
      }

    def retry_on(sym)
      yield
      if now?(sym)
        submit(:login)
        yield
      end
    end

    def required(sym)
      go(sym) unless now?(sym)
    end

    alias :__orig_now? :now?
    def now?(sym_or_regexp)
      if page.nil?
        nil
      elsif sym_or_regexp.is_a? Regexp
        sym_or_regexp.match page.uri.to_s
      else
        __orig_now? sym_or_regexp
      end
    end

  end

end

