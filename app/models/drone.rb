class Drone < ApplicationRecord
  # DBテーブル関連付け
  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
  
  has_many :flights, foreign_key: 'drone_registration_id', primary_key: 'drone_registration_id'
  
  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
  # DBテーブル関連付け


  # バリデーション
  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
  
  # ドローンID：入力必須
  #「JU」以降13文字の英数字が続く
  validates :drone_registration_id, 
  presence: true, format: { 
    with: /\AJU[\dA-Z]{11}\z/, 
    message: "はJUから始まる13文字の英数字でなければなりません" 
  }

  # ドローンの総飛行時間：秒数として保存し、必ず0秒以上である
  # 初期値は0
  validates :total_flight_time, 
  numericality: { greater_than_or_equal_to: 0 }
  
  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
  # バリデーション

end