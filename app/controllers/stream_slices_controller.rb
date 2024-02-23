class StreamSlicesController < ApplicationController
  include ActiveStorage::SetCurrent

  def show
    @stream_slice = StreamSlice.find_by!(slug: params.require(:id))

    respond_to do |format|
      format.json
      format.html
      format.m3u8
    end
  end
end
