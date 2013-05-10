require 'active_support/concern'
require 'active_support/dependencies/autoload'
require 'ooor'
require 'ooor/base'

require "action_controller"

module Ooorest
  module ActionWindowController
    extend AbstractController::Callbacks

    # GET /res_partners
    # GET /res_partners.json
    def index(args=nil)
      @local_params = args
      @domain = eval((params.delete(:domain) || "[]").gsub("(","[").gsub(")","]"))
      @offset = params.delete(:offset) || false
      @limit = params.delete(:limit) || false
      @order = params.delete(:order) || false
      @count = params.delete(:count) || false
      @field_names = params.delete(:fields) || @fields.keys
      #TODO find ids using pagination
      @objects = @abstract_model.find(:all, :domain=>@domain, :fields=>@field_names, :context => @context)#TODO plug on read?

      respond_to do |format|
        format.html # index.html.erb
        format.json  { render :json => @objects, :layout => false }
        format.xml  { render :xml => @objects, :layout => false }
      end
    end

    # GET /res_partners/1
    # GET /res_partners/1.json
    def show(args=nil)
      @local_params = args
      respond_to do |format|
        format.html # show.html.erb
        format.xml { render xml: @object }
        format.json { render json: @object }
      end
    end

    # GET /res_partners/new
    # GET /res_partners/new.json
    def new(args=nil)
      @local_params = args
      @object = @abstract_model.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @object }
      end
    end

    # GET /res_partners/1/edit
    def edit(args=nil)
      @local_params = args
      respond_to do |format|
        format.html # edit.html.erb        
      end
    end

    # POST /res_partners
    # POST /res_partners.json
    def create(args=nil)
      @local_params = args
      respond_to do |format|
        if @object.save
          format.html { redirect_to @object, notice: 'Res partner was successfully created.' }
          format.json { render json: @object, status: :created, location: @res_partner }
        else
          format.html { render action: "new" }
          format.json { render json: @object.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /res_partners/1
    # PUT /res_partners/1.json
    def update(args=nil)
      @local_params = args
      respond_to do |format|
        if @object.update_attributes(params[:res_partner])
          format.html { redirect_to @object, notice: 'Res partner was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @object.errors, status: :unprocessable_entity }
        end
      end
    end

#TODO TODO TODO FIXME FIXME FIXME
  def search(args=nil)
    @local_params = args
    @domain = eval((params.delete(:domain) || "[]").gsub("(","[").gsub(")","]"))
    @offset = params.delete(:offset) || false
    @limit = params.delete(:limit) || false
    @order = params.delete(:order) || false
    @count = params.delete(:count) || false
    @context = context_from_params(params)
    @ids = model_class.search(@domain, @offset, @limit, @order, @context, @count)

    respond_to do |format|
      format.html { render :xml => @ids, :layout => false }# index.html.erb
      format.json  { render :json => @ids, :layout => false }
      format.xml  { render :xml => @ids, :layout => false }
    end
  end

  def call(args=nil)
    @local_params = args
    @context = context_from_params(params)
    method =  @context.delete(:method)
    arguments = eval("[" + @context.delete(:param_string) + "]")
    #@context.delete(:args)
    ids = ids_from_param(@context.delete(:id))
    @context.keys.each do |key|
      @context[key] = @context[key].to_i if @context[key] == @context[key].to_i.to_s
    end
    if ids
      ids = [ids.to_i] unless ids.is_a? Array
      res = model_class.rpc_execute(method, ids, *arguments + [@context])#, @context)
    else
      res = model_class.rpc_execute(method, *arguments + [@context]) #TODO
    end
    respond_to do |format|
      format.html { render :xml => res, :layout => false }# show.html.erb
      format.xml  { render :xml => res, :layout => false }
      format.json  { render :json => res, :layout => false }
    end
  end

    def copy(args=nil)
    @local_params = args
      render :json => "TODO", :layout => false
    end

    def wkf_action(args=nil)
    @local_params = args
      render :json => "TODO", :layout => false
    end

    def on_change(args=nil)
    @local_params = args
      render :json => "TODO", :layout => false
    end

    private
      
    def _authenticate!
      instance_eval &Ooorest.authenticate_with
    end

    def _authorize!
      instance_eval &Ooorest.authorize_with
    end

    def _audit!
      instance_eval &Ooorest.audit_with
    end

    def _current_user
      instance_eval &Ooorest.current_user_method
    end

    def params
      @local_params || super
    end

    def get_model_meta
      get_model
    end

    def to_model_name(param)
      @oe_model_name = param.gsub('-', '.')
      Ooor::Base.class_name_from_model_key(@oe_model_name)
    end

    def get_model
      @model_path = params[:model_name]
      @model_name = to_model_name(params[:model_name])
      raise Ooorest::ModelNotFound unless (@abstract_model = Ooor.connection(params).const_get(@oe_model_name))
    end

    def get_object
#       if params[:id].index(",")
#         @ids = params[:id].gsub('[', '').gsub(']', '').split(',').map {|i| i.to_i}
#       end
      raise Ooorest::ObjectNotFound unless (@object = @abstract_model.find(params[:id], context: @context)) #TODO support multiple ids
    end

  end
end