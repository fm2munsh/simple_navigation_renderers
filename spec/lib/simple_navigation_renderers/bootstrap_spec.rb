require 'spec_helper'
require 'action_view'

describe SimpleNavigationRenderers::Bootstrap do

  describe '.render' do

    # tested navigation content
    def fill_in(primary)
      primary.item :news, { icon: 'fa fa-fw fa-bullhorn', text: 'News' }, 'news_index_path'
      primary.item :concerts, 'Concerts', 'concerts_path', html: { class: 'to_check_header', header: true }
      primary.item :video, 'Video', 'videos_path', html: { class: 'to_check_split', split: true }
      primary.item :divider_before_info_index_path, '', '#', html: { divider: true }
      primary.item :info, { icon: 'fa fa-fw fa-book', title: 'Info' }, 'info_index_path', html: { split: true } do |info_nav|
        info_nav.item :main_info_page, 'Main info page', 'main_info_page'
        info_nav.item :about_info_page, 'About', 'about_info_page'
        info_nav.item :divider_before_misc_info_pages, '', '#', html: { divider: true }
        info_nav.item :misc_info_pages, 'Misc.', 'misc_info_pages', html: { split: true } do |misc_nav|
          misc_nav.item :header_misc_pages, 'Misc. Pages', '#', html: { class: 'to_check_header2', header: true }
          misc_nav.item :page1, 'Page1', 'page1'
          misc_nav.item :page2, 'Page2', 'page2'
        end
        info_nav.item :divider_before_contact_info_page, '', '#', html: { divider: true }
        info_nav.item :contact_info_page, 'Contact', 'contact_info_page'
      end
      primary.item :signed_in, 'Signed in as Pavel Shpak', '#', html: { class: 'to_check_navbar_text', navbar_text: true }
    end


    # 'stub_name' neads to check raising error when invalid 'Item name hash' provided
    #
    def render_result(renderer, stub_name = false)
      prepare_navigation_instance(renderer)
      main_menu = build_main_menu(stub_name).render(expand_all: true)
      html_document(main_menu)
    end


    def bootstrap3_renderer
      SimpleNavigationRenderers::Bootstrap3
    end


    def bootstrap2_renderer
      SimpleNavigationRenderers::Bootstrap2
    end


    def simple_navigation_adapter
      SimpleNavigation::Adapters::Rails.new(
        double(:context, view_context: ActionView::Base.new)
      )
    end


    def prepare_navigation_instance(renderer)
      SimpleNavigation::Configuration.instance.renderer = renderer
      allow(SimpleNavigation).to receive_messages(adapter: simple_navigation_adapter)
      allow_any_instance_of(SimpleNavigation::Item).to receive_messages(selected?: false, selected_by_condition?: false)
    end


    def build_main_menu(stub_name)
      # Create a new container
      main_menu = SimpleNavigation::ItemContainer.new(1)
      # Fill it with menu
      fill_in(main_menu)
      # Mark one entry as selected
      selected = main_menu.items.find { |item| item.key == :news }
      allow(selected).to receive_messages(selected?: true, selected_by_condition?: true)
      # Stub if needed
      main_menu.items[0].instance_variable_set(:@name, {}) if stub_name
      # Return menu
      main_menu
    end


    def bootstrap3_navigation(opts = {})
      stub_name = opts.delete(:stub_name){ false }
      render_result(bootstrap3_renderer, stub_name)
    end


    def bootstrap2_navigation(opts = {})
      stub_name = opts.delete(:stub_name){ false }
      render_result(bootstrap2_renderer, stub_name)
    end


    def html_document(html)
      Loofah.fragment(html)
    end


    def check_selector(nav_menu, selector, nb_entries = 1)
      expect(nav_menu.css(selector)).to have(nb_entries).entries
    end


    context "for 'bootstrap3' renderer" do
      it "wraps main menu in ul-tag with 'nav navbar-nav' classes" do
        check_selector bootstrap3_navigation, 'ul.nav.navbar-nav'
      end
    end


    context "for 'bootstrap2' renderer" do
      it "wraps main menu in ul-tag with 'nav' class" do
        check_selector bootstrap2_navigation, 'ul.nav.navbar-nav', 0
        check_selector bootstrap2_navigation, 'ul.nav'
      end
    end


    it "sets up 'active' class on selected items (on li-tags)" do
      check_selector bootstrap3_navigation, 'ul.nav.navbar-nav > li.active > a[href="news_index_path"]'
    end


    it "wraps submenu in ul-tag 'dropdown-menu' class" do
      check_selector bootstrap3_navigation, 'ul > li > ul.dropdown-menu > li > ul.dropdown-menu'
    end


    context "for the first level submenu (the second level menu)" do
      it "sets up 'dropdown' class on li-tag which contains that submenu" do
        check_selector bootstrap3_navigation, 'ul > li.dropdown'
      end

      it "sets up 'dropdown-toggle' class on link-tag which is used for toggle that submenu" do
        check_selector bootstrap3_navigation, 'ul > li.dropdown > a.dropdown-toggle'
      end

      it "sets up 'data-toggle' attribute to 'dropdown' on link-tag which is used for toggle that submenu" do
        check_selector bootstrap3_navigation, 'ul > li.dropdown > a[data-toggle=dropdown]'
      end

      it "sets up 'data-target' attribute to '#' on link-tag which is used for toggle that submenu" do
        check_selector bootstrap3_navigation, 'ul > li.dropdown > a[data-target="#"]'
      end

      it "sets up 'href' attribute to '#' on link-tag which is used for toggle that submenu" do
        check_selector bootstrap3_navigation, 'ul > li.dropdown > a[href="#"]'
      end

      it "puts b-tag with 'caret' class in li-tag which contains that submenu" do
        check_selector bootstrap3_navigation, 'ul > li.dropdown > a[href="#"] > b.caret'
      end
    end


    context "for nested submenu (the third level menu and deeper)" do
      it "sets up 'dropdown-submenu' class on li-tag which contains that submenu" do
        check_selector bootstrap3_navigation, 'ul > li > ul.dropdown-menu > li.dropdown-submenu'
      end
    end


    context "when ':split' option provided" do
      context "for the first level item which contains submenu" do
        it "splits item on two li-tags (left and right) and right li-tag will contain the first level submenu (second level menu)" do
          check_selector bootstrap3_navigation, 'ul > li.dropdown-split-left + li.dropdown.dropdown-split-right > ul.dropdown-menu'
        end

        it "sets up 'pull-right' class on ul-tag which is the submenu" do
          check_selector bootstrap3_navigation, 'ul > li > ul.dropdown-menu.pull-right'
        end
      end

      context "for the second level item and deeper which contains submenu" do
        it "does not splits item on two li-tags" do
          check_selector bootstrap3_navigation, 'ul.dropdown-menu > li.dropdown-split-left + li.dropdown.dropdown-split-right > ul.dropdown-menu', 0
          check_selector bootstrap3_navigation, 'ul.dropdown-menu > li.dropdown-submenu > ul.dropdown-menu'
        end

        it "does not sets up 'pull-right' class on ul-tag which is the submenu" do
          check_selector bootstrap3_navigation, 'ul.dropdown-menu > li > ul.dropdown-menu.pull-right', 0
        end
      end

      context "for item which does not contain submenu" do
        it "does not splits item on two li-tags" do
          check_selector bootstrap3_navigation, 'ul > li.to_check_split.dropdown-split-left + li.dropdown.dropdown-split-right', 0
          check_selector bootstrap3_navigation, 'ul > li.to_check_split'
        end
      end
    end


    context "when ':navbar_text' option provided" do
      it "creates p-tag with class 'navbar-text' and item 'name' as a content instead of link-tag for the item (standard item)" do
        check_selector bootstrap3_navigation, 'ul > li.to_check_navbar_text > a', 0
        check_selector bootstrap2_navigation, 'ul > li.to_check_navbar_text > a', 0

        expect(bootstrap3_navigation.css('ul > li.to_check_navbar_text > p.navbar-text')[0].children[0].to_s).to eq 'Signed in as Pavel Shpak'
        expect(bootstrap2_navigation.css('ul > li.to_check_navbar_text > p.navbar-text')[0].children[0].to_s).to eq 'Signed in as Pavel Shpak'
      end
    end


    context "when ':divider' option provided" do
      it "does not create link-tag for the item (standard item)" do
        check_selector bootstrap3_navigation, 'ul > li.divider-vertical + li > a[href="divider_before_info_index_path"]', 0
        check_selector bootstrap3_navigation, 'ul.dropdown-menu > li.divider + li > a[href="divider_before_misc_info_pages"]', 0
        check_selector bootstrap3_navigation, 'ul.dropdown-menu > li.divider + li > a[href="divider_before_contact_info_page"]', 0
      end

      context "for the first level item" do
        it "adds li-tag with class 'divider-vertical'" do
          check_selector bootstrap3_navigation, 'ul > li.divider-vertical + li > a[href="info_index_path"]'
        end
      end

      context "for the second level item and deeper" do
        it "adds li-tag with class 'divider'" do
          check_selector bootstrap3_navigation, 'ul.dropdown-menu > li.divider + li > a[href="misc_info_pages"]'
          check_selector bootstrap3_navigation, 'ul.dropdown-menu > li.divider + li > a[href="contact_info_page"]'
        end
      end
    end


    context "when ':header' option provided" do
      context "for the first level item" do
        it "does not set up 'dropdown-header' or 'nav-header' class on li-tag" do
          check_selector bootstrap3_navigation, 'ul.nav.navbar-nav > li.to_check_header.dropdown-header', 0
          check_selector bootstrap2_navigation, 'ul.nav > li.to_check_header.nav-header', 0
        end

        it "creates link-tag for the item (standard item)" do
          check_selector bootstrap3_navigation, 'ul.nav.navbar-nav > li.to_check_header > a'
          check_selector bootstrap2_navigation, 'ul.nav > li.to_check_header > a'
        end
      end

      context "for the second level item and deeper" do
        context "for 'bootstrap3' renderer" do
          it "sets up 'dropdown-header' class on li-tag" do
            check_selector bootstrap3_navigation, 'ul.dropdown-menu > li.to_check_header2.dropdown-header'
          end
        end

        context "for 'bootstrap2' renderer" do
          it "sets up 'nav-header' class on li-tag" do
            check_selector bootstrap2_navigation, 'ul.dropdown-menu > li.to_check_header2.nav-header'
          end
        end

        it "does not create link-tag for the item (standard item), but puts only item 'name'" do
          check_selector bootstrap3_navigation, 'ul.dropdown-menu > li.to_check_header2.dropdown-header > a', 0
          check_selector bootstrap2_navigation, 'ul.dropdown-menu > li.to_check_header2.nav-header > a', 0

          expect(bootstrap3_navigation.css('ul.dropdown-menu > li.to_check_header2.dropdown-header')[0].children[0].to_s).to eq 'Misc. Pages'
          expect(bootstrap2_navigation.css('ul.dropdown-menu > li.to_check_header2.nav-header')[0].children[0].to_s).to eq 'Misc. Pages'
        end
      end
    end


    context "when 'hash' provided in place of 'name'" do
      context "with ':icon' parameter" do
        it "adds span-tag with classes from the parameter" do
          check_selector bootstrap3_navigation, 'ul > li > a > span.fa.fa-fw.fa-bullhorn'
        end
      end

      context "with ':title' parameter" do
        it "sets up 'title' attribute on icon's span-tag to the parameter value" do
          check_selector bootstrap3_navigation, 'ul > li > a > span.fa.fa-fw.fa-book[title="Info"]'
        end
      end

      context "with ':text' parameter" do
        it "uses the parameter value as 'name' of the item" do
          expect(bootstrap3_navigation.css('ul > li > a > span.fa.fa-fw.fa-bullhorn')[0].parent.children[1].to_s).to eq ' News'
        end
      end

      context "without ':text' and ':icon' parameters" do
        it "raises 'InvalidHash' error" do
          expect {
            bootstrap3_navigation(stub_name: true)
          }.to raise_error(SimpleNavigationRenderers::InvalidHash)
        end
      end
    end

  end
end
