class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  #ページ出力前に１ヶ月分のデータの存在を確認・セットする
  def set_one_month
    @first_day = Date.current.beginning_of_month
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
    #ユーザーに紐付く１ヶ月分のレコードを検索し取得
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day)
    
    #対象の月の日数とユーザーに紐付く１ヶ月分のレコードの日数が一致するか評価
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do #トランザクションを開始
        #繰り返し処理により１ヶ月分の勤怠データを生成
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
    end
    
  rescue ActiveRecord::RecordInvalid #トランザクションによるエラー分岐
    flash[:danager] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
end
