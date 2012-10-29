module Rich
  class FilesController < ApplicationController

    before_filter :authenticate_rich_user

    layout "rich/application"
    
    def index
      @type = params[:type]
      
      if(params[:scoped] == 'true')
        if(@type == "image")
          @items = RichFile.images.order("created_at DESC").where("owner_type = ? AND owner_id = ?", params[:scope_type], params[:scope_id]).page params[:page]
        else
          @items = RichFile.files.order("created_at DESC").where("owner_type = ? AND owner_id = ?", params[:scope_type], params[:scope_id]).page params[:page]
        end        
      else
        if(@type == "image")
          @items = RichFile.images.order("created_at DESC").page params[:page]
        else
          @items = RichFile.files.order("created_at DESC").page params[:page]
        end        
      end
      
      # stub for new file
      @rich_asset = RichFile.new :simplified_type => @type
      
      respond_to do |format|
        format.js
        format.html
      end
      
    end
    
    def show
      # show is used to retrieve single files through XHR requests after a file has been uploaded
      
      if(params[:id])
        # list all files
        @file = RichFile.find(params[:id])
        render :layout => false
      else 
        render :text => "File not found"
      end
      
    end
    
    def create
      @file = RichFile.new(params[:rich_file]) #make sure the type is set

      if(params[:scoped] == 'true')
        @file.owner_type = params[:scope_type]
        @file.owner_id = params[:scope_id].to_i
      end
      
      if @file.save
        redirect_to :back
      else
        render :json => { :success => false, 
                          :error => "Could not upload your file:\n- "+@file.errors.to_a[-1].to_s,
                          :params => params.inspect }
      end
    end
    
    def destroy  
      if(params[:id])
        rich_file = RichFile.delete(params[:id])
        @fileid = params[:id]
      end
    end
    
  end
end