class FlightsController < ApplicationController
  include Helper

  def index
    # ドローンを特定
    drone = Drone.find_by(drone_registration_id: params[:drone_registration_id])
    if drone
      # 指定したドローンに紐づく飛行記録を全て取得
      flights = drone.flights
      flight_total_times = format_seconds_to_time(drone.total_flight_time)
      render json: { 
        drone_registration_id: drone.drone_registration_id,
        flights: flights.as_json(only: [:pilot_id, :take_off_latitude, :take_off_longitude, :landing_latitude, :landing_longitude, :take_off_time, :landing_time]),
        total_flight_time: flight_total_times
      }
    else
      render json: { error: "指定したドローンは見つかりませんでした。" }, status: :not_found
    end
  end


  def create
    saved_flights = []
    error_messages = []

    params[:flights] = JSON.parse(request.raw_post) # パラメータをラップ

    ActiveRecord::Base.transaction do
      params[:flights].each do |flight_param|
        drone = Drone.find_by(drone_registration_id: flight_param[:droneRegistrationId].to_s)
        unless drone
          drone = Drone.create(drone_registration_id: flight_param[:droneRegistrationId].to_s)
        end
        
        flight = drone.flights.build(
          drone_registration_id: drone.drone_registration_id,
          pilot_id: flight_param[:pilotId],
          take_off_latitude: flight_param[:takeOffLatitude],
          take_off_longitude: flight_param[:takeOffLongitude],
          landing_latitude: flight_param[:landingLatitude],
          landing_longitude: flight_param[:landingLongitude],
          take_off_time: flight_param[:takeOffTime],
          landing_time: flight_param[:landingTime]
        )
      
        # うまく保存できない場合、今回の操作を全てロールバック
        if flight.save
          saved_flights << flight
        else
          error_messages << flight.errors.full_messages
          raise ActiveRecord::Rollback
        end
      end
    end
  
    # エラーメッセージがある場合はエラーレスポンスを返す
    unless error_messages.empty?
      render json: { errors: error_messages.flatten }, status: :unprocessable_entity
      return
    end  
    # すべて成功した場合は成功レスポンスを返す
    render json: { message: "飛行記録が正しく保存されました", flight_ids: saved_flights.map(&:drone_registration_id) }, status: :created
  end
end