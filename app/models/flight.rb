class Flight < ApplicationRecord
  # DBテーブル関連付け
  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

  belongs_to :drone, foreign_key: 'drone_registration_id', primary_key: 'drone_registration_id'
  
  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
  # DBテーブル関連付け


  # 保存後処理
  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

  # ドローンの総飛行時間を累計
  after_save :update_total_flight_time

  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
  # 保存後処理


  # バリデーション
  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

  # ドローンID：入力必須
  # 「JU」以降13文字の英数字が続く
  validates :drone_registration_id, 
  presence: true, format: { 
    with: /\AJU[\dA-Z]{11}\z/, 
    message: "はJUから始まる13文字の英数字でなければなりません" 
  }
  
  # パイロットID：入力必須
  # 「PL」以降13文字の英数字が続く
  validates :pilot_id, 
  presence: true, format: { 
    with: /\APL[\dA-Z]{11}\z/, 
    message: "はAPLから始まる13文字の英数字でなければなりません" 
  }

  # 緯度：入力必須
  # 離陸および着陸の緯度は「-90 <= 緯度 <= 90」を満たす
  validates :take_off_latitude, :landing_latitude, 
  presence: true, numericality: { 
    greater_than_or_equal_to: -90, 
    less_than_or_equal_to: 90, 
    message: "は-90度〜90度の間でなければなりません" 
  }

  # 経度：入力必須
  # 離陸および着陸の経度は「-180 <= 経度 <= 180」を満たす
  validates :take_off_longitude, :landing_longitude, 
  presence: true, numericality: { 
    greater_than_or_equal_to: -180, 
    less_than_or_equal_to: 180, 
    message: "は-180度〜180度の間でなければなりません" 
  }
  
  # 同じ機体は重複した時間帯で飛行できない
  validate :unique_flight_time_for_drone
 
  # 離陸日時が着陸日時よりも前である
  validate :take_off_before_landing


  # ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
  # バリデーション


  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
  private # 補助メソッド

  def take_off_before_landing
    return if take_off_time.blank? || landing_time.blank?
    if take_off_time >= landing_time
      errors.add(:take_off_time, "は着陸日時よりも前でなければなりません")
    end
  end

  def update_total_flight_time
    flight_time = (landing_time - take_off_time)
    # 飛行時間を秒単位で計算
    total_flight_time = (drone.total_flight_time + flight_time.to_i)
    drone.update(total_flight_time: total_flight_time.to_i)
  end

  def unique_flight_time_for_drone
    # 同じ機体の他の飛行記録を検索
    overlapping_flights = Flight.where(drone_registration_id: drone_registration_id).where.not(id: id)
    .where("(take_off_time BETWEEN ? AND ?) OR (landing_time BETWEEN ? AND ?)",
           take_off_time, landing_time, take_off_time, landing_time)

    if overlapping_flights.exists?
      errors.add(:base, "同じ機体が重複飛行しています")
    end
  end

  #＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

end