class BillsController < ApplicationController
    before_action :authenticate_account!, only: [:show, :new, :create, 
    :edit, :destroy]
    before_action :correct_account, only: [:show, :edit, :update, :destroy]
    
    
  def index
    if account_signed_in?
      @bills = Bill.where(:account_id => current_account.id).order(date: :desc)
      @users = User.where(:account_id => current_account.id)
    end
  end
  
  def new
    @bill = Bill.new
  end
  
  def create
    @bill = Bill.new(bill_params)
    if @bill.save
      redirect_to @bill
    else
      render 'new'
    end
  end
  
  def show
    @bill = Bill.find(params[:id])
    @charges = @bill.charges
  end
  
  def edit
    @bill = Bill.find(params[:id])
  end
  
  def update
    @bill = Bill.find(params[:id])
    if @bill.update_attributes(bill_params)
      flash[:success] = "Bill updated!"
      redirect_to @bill
    else
      render 'edit'
    end
  end
  
  def destroy
    @bill = Bill.find(params[:id])
    @bill.destroy
    flash[:success] = "Bill deleted!"
    redirect_to bills_url
  end
  
  def send_bill
    @bill = Bill.find(params[:id])
    BillMailer.mail_bill(@bill).deliver_later
    flash[:success] = "Bill sent!"
    redirect_to root_path_url
  end
  
  private
    
    def bill_params
      params.require(:bill).permit(:date, :amount, :total_data, 
        :data_cost, :account_id, :data_overage)
    end
    
    def correct_account
      @bill = Bill.find(params[:id])
      unless (@bill.account_id == current_account.id)
          flash[:danger]="That bill doesn't belong to you!"
          redirect_to root_path_url
      end
    end
end