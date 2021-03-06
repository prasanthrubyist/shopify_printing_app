class OrdersController < ApplicationController
  protect_from_forgery :except => 'print'
  
  around_filter :shopify_session


  def index
    # get latest 3 orders
    @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 3, :order => "created_at DESC" })
    # get all printing templates for the current shop
    @tmpls  = shop.templates
  end
  
  
  def show
    @order = ShopifyAPI::Order.find(params[:id])
    
    respond_to do |format|
      format.html do
        @tmpls = shop.templates
      end
      format.js do
        # AJAX preview, loads in modal Dialog
        @tmpl = shop.templates.find(params[:template_id])
        @rendered_template = @tmpl.render(@order.to_liquid)
        render :partial => 'preview', :locals => {:tmpl => @tmpl, :rendered_template => @rendered_template}
      end
    end
  end

  # return the raw rendered HTML content to refer to from an IFrame
  def preview
    @tmpl  = shop.templates.find(params[:template_id])
    @order = ShopifyAPI::Order.find(params[:id])
    @rendered_template = @tmpl.render(@order.to_liquid)

    render :text => @rendered_template
  end

  def print
    @all_templates = shop.templates
    @printed_templates = @all_templates.find(params[:print_templates])
    
    @all_templates.each { |tmpl| tmpl.update_attribute(:default, @printed_templates.include?(tmpl)) }
    head 200
  end
end