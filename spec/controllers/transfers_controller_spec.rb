# encoding: UTF-8
require 'spec_helper'

describe TransfersController do
  before do
    @origin = FactoryGirl.build(:attendance)
    @origin.id = 3
    @destination = FactoryGirl.build(:attendance)
    @destination.id = 5

    Attendance.stubs(:find).with('3').returns(@origin)
    Attendance.stubs(:find).with('5').returns(@destination)

    @user = FactoryGirl.build(:user)
    disable_authorization
    sign_in @user
  end
  describe 'GET new' do
    it 'should be successful' do
      get :new

      response.code.should == '200'
    end
    it 'should set potential destinations as all pending attendances' do
      Attendance.stubs(:pending).returns([@origin, @destination])

      get :new

      assigns[:destinations].should == [@origin, @destination]
    end

    context 'empty' do
      it 'should set event to fake event' do
        get :new

        assigns[:event].should be_new_record
      end
      it 'should set empty transfer' do
        get :new

        assigns[:transfer].should be_new_record
        assigns[:transfer].origin_id.should be_nil
        assigns[:transfer].destination_id.should be_nil
      end
    end
    context 'with origin' do
      it 'should set event' do
        get :new, transfer: {origin_id: 3}

        assigns[:event].should == @origin.event
      end
      it 'should set transfer origin' do
        get :new, transfer: {origin_id: 3}

        assigns[:transfer].origin.should == @origin
      end
    end
    context 'with destination' do
      it 'should set event' do
        get :new, transfer: {destination_id: 5}

        assigns[:event].should == @destination.event
      end
      it 'should set transfer destination' do
        get :new, transfer: {destination_id: 5}

        assigns[:transfer].destination.should == @destination
      end
    end
    context 'with origin and destination' do
      it 'should set event according to origin' do
        get :new, transfer: {origin_id: 3, destination_id: 5}

        assigns[:event].should == @origin.event
      end
      it 'should set transfer origin and destination' do
        get :new, transfer: {origin_id: 3, destination_id: 5}

        assigns[:transfer].origin.should == @origin
        assigns[:transfer].destination.should == @destination
      end
    end
    
    context 'as an organizer' do
      before do
        @user.add_role :organizer
      end
      it 'should set potential transfer origins as all paid or confirmed attendances' do
        Attendance.expects(:paid).returns([@origin, @destination])

        get :new

        assigns[:origins].should == [@origin, @destination]
      end
    end
    context 'as a guest' do
      it 'should set potential transfer origins as its own paid or confirmed attendances' do
        continuation = mock
        @user.expects(:attendances).returns(continuation)
        continuation.expects(:paid).returns([@origin, @destination])
        
        get :new

        assigns[:origins].should == [@origin, @destination]
      end
    end
  end

  describe 'POST create' do
    it 'should set transfer according to post parameters' do
      transfer = Transfer.build(origin_id: '3', destination_id: '5')
      Transfer.expects(:build).with('origin_id' => '3', 'destination_id' => '5').returns(transfer)

      post :create, transfer: {origin_id: 3, destination_id: 5}
    end
    context 'successful transfer' do
      before do
        @origin.stubs(:save).returns(true)
        @destination.stubs(:save).returns(true)
      end
      it 'should set success flash message' do
        post :create, transfer: {origin_id: 3, destination_id: 5}

        flash[:notice].should == I18n.t('flash.transfer.success')
      end
      it 'should redirect to new confirmed (or paid) attendance' do
        post :create, transfer: {origin_id: 3, destination_id: 5}

        response.should redirect_to(attendance_path(id: 3))
      end
      it 'should save the transfer' do
        transfer = Transfer.new(@origin, @destination)
        Transfer.expects(:build).with('origin_id' => '3', 'destination_id' => '5').returns(transfer)
        transfer.expects(:save)

        post :create, transfer: {origin_id: 3, destination_id: 5}
      end
    end
    context 'forbidden transfer' do
      before do
        @origin.stubs(:save).returns(false)
        @destination.stubs(:save).returns(false)
      end
      it 'should render transfer form again' do
        post :create, transfer: {origin_id: 3, destination_id: 5}

        response.should render_template(:new)
      end
      it 'should show flash error message' do
        post :create, transfer: {origin_id: 3, destination_id: 5}

        flash[:error].should == I18n.t('flash.transfer.failure')
      end
    end
  end
end
