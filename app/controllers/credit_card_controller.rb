class CreditCardController < ApplicationController

  require "payjp"

  def index
    @card = current_user.credit_card
    @parents = Category.roots

    if @card.blank?
      render action: :index 
    else
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"] #payjpの秘密鍵をセット。

      customer = Payjp::Customer.retrieve(@card.customer_id)
        #保管した顧客IDでpayjpから情報取得
      @customer_card = customer.cards.retrieve(@card.card_id)
        #保管したカードIDでpayjpから情報取得、カード情報表示のためインスタンス変数に代入

        #保管されているブランドによって表示させる画像を変更する
      @card_brand = @customer_card.brand      
      case @card_brand
      when "Visa"
        @card_src = "visa.png"
      when "JCB"
        @card_src = "jcb.png"
      when "MasterCard"
        @card_src = "master-card.png"
      when "American Express"
        @card_src = "american_express.png"
      when "Diners Club"
        @card_src = "dinersclub.png"
      when "Discover"
        @card_src = "discover.png"
      when "Saison"
        @card_src = "saison-card.png"
      end

    end
  end

  def new

  end

  def registration #payjpとCardのデータベース作成を実施します。(カード登録)
    
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"] #payjpの秘密鍵をセット。
    if params['payjpToken'].blank?
      # paramsの中にjsで作った'payjpTokenが存在するか確かめる
      redirect_to action: "new"
    else
      customer = Payjp::Customer.create(
      # description: '登録テスト', #なくてもOK
      # email: user.email, #なくてもOK
      card: params['payjpToken'],
      metadata: {user_id: current_user.id}
      ) #念の為metadataにuser_idを入れましたがなくてもOK?
      # ↑ここ(else以降)でjay.jpに保存

      @card = CreditCard.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
      # ↑ ここでdbのCreditCardテーブルに「user_id」、「customer_id」、「card_id」を保存

      if @card.save
        redirect_to controller: "mypage", action: 'index'
        flash[:notice] = 'クレジットカードを登録しました。'
      else
        redirect_to action: "registration"
      end
    end
  end

  def buy #購入機能

    card = current_user.credit_card
     # テーブル紐付けてるのでログインユーザーのクレジットカードを引っ張ってくる（ダミーユーザーのカード）

    if card.blank?
      redirect_to action: "new"
      flash[:alert] = '購入にはクレジットカード登録が必要です'
    else
      @product = Product.find(params[:id])
     # 購入する商品を定義する

      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
     #payjpの秘密鍵をセット。

      Payjp::Charge.create(
      amount: @product.price, #支払金額
      customer: card.customer_id, #顧客ID
      currency: 'jpy', #日本円
      )
     # ↑商品の金額をamountへ、cardの顧客idをcustomerへ、currencyをjpyへ入れる

      if @product.update(purchase: 1, buyer_id: current_user.id)
       # ↑購入が完了したら購入商品のレコードのpurchaseカラムに１を、buyer_idカラムに購入者idを入れる
        flash[:notice] = '購入しました。'
        redirect_to controller: "posts", action: 'toppage'
      else
        flash[:alert] = '購入に失敗しました。'
        redirect_to controller: "purchases", action: 'show'
      end
    end
  end

  def delete #クレジットカード削除機能

    card = current_user.credit_card
     # テーブル紐付けてるのでログインユーザーのクレジットカードを引っ張ってくる（ダミーユーザーのカード）

    if card.blank?
      redirect_to action: "new"
    else
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"] #payjpの秘密鍵をセット。
      customer = Payjp::Customer.retrieve(card.customer_id)
      customer.delete
     #ここでpay.jpの方を消している
      if card.delete
     #ここでテーブルにあるcardデータを消している
        flash[:alert] = 'カード情報を削除しました。'
        redirect_to controller: "mypage", action: 'index'
      end
    end  
  end

end
