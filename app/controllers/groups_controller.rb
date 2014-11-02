class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
    if params[:edit]
      @users = User.find_by_sql("select u.* from groups g, groups_users gu, users u where gu.group_id = g.id and gu.user_id = u.id and g.id = '#{@group.id}'")
    end
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render action: 'show', status: :created, location: @group }
      else
        format.html { render action: 'new' }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    if params[:user_name]
      logger.debug "in add users"
      @user = User.find_by_name(params[:user_name])
      if @user
        notice = @user.add_group(@group.name)
      else
        notice = "There is no user by that name."
      end
      flash[:notice] = notice
      redirect_to edit_group_url(@group, :edit => "add_users")
    elsif params[:edit] == "remove_users"
      logger.debug "in remove users"
      @user = User.find(params[:user_id])
      notice = @user.remove_group(@group.name)
      flash[:notice] = notice
      redirect_to edit_group_url(@group, :edit => "remove_users")
    else
      respond_to do |format|
        if @group.update(group_params)
          logger.debug "Updating group data"
          format.html { redirect_to @group, notice: 'Group was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @group.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    if @group.users
      flash[:notice] = "I'm sorry, this group still has users and cannot be deleted."
    else
      @group.destroy
    end
    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :description)
    end

    def edit_params
      params.permit(:user_name)
      params.permit(:edit)
    end
end
