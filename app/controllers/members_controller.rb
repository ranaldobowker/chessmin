class MembersController < ApplicationController
  before_action :set_member,     only: %i[ show edit update destroy ]
  before_action :set_active_nav, only: %i[ index show new edit ]

  # GET /members or /members.json
  def index
    @members = Member.all
  end

  # GET /members/1 or /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members or /members.json
  def create
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: "Member was successfully created." }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @member.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /members/1 or /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: "Member was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @member.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /members/1 or /members/1.json
  def destroy
    @member.destroy!

    # re-rank the remaining members after a member is destroyed
    Member.where("current_rank > ?", @member.current_rank).update_all("current_rank = current_rank - 1")

    respond_to do |format|
      format.html { redirect_to members_path, notice: "Member was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_active_nav
    @nav = :members
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_member
    @member = Member.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def member_params
    params.expect(member: [ :name, :surname, :email_address, :birthday, :club_games_played ])
  end
end
