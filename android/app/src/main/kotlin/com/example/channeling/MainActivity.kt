package com.example.channeling

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val methodChannelName = "com.example.channeling/method"
    private val eventChannelName = "com.example.channeling/event"

    private var methodChannel :MethodChannel? =null
    private var pressureChannel : EventChannel? =null
    private var pressureStreamHandler:CustomStreamHandler?=null

    private lateinit var sensorManager : SensorManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
                super.configureFlutterEngine(flutterEngine)
        setupChannels(
this,flutterEngine.dartExecutor.binaryMessenger
        );
    }

    override fun onDestroy() {
        tearDownChannel()
        super.onDestroy()
    }

    private fun setupChannels(context : Context, messenger:BinaryMessenger){
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        methodChannel= MethodChannel(messenger,methodChannelName)
        methodChannel!!.setMethodCallHandler{
            call,result ->
                if(call.method=="getMethodChannel"){
                result.success(sensorManager.getSensorList(Sensor.TYPE_PRESSURE).isNotEmpty())
            }
            else{result.notImplemented()}
        }

        pressureChannel= EventChannel(messenger,eventChannelName)
        pressureStreamHandler= CustomStreamHandler(sensorManager,Sensor.TYPE_PRESSURE)
        pressureChannel!!.setStreamHandler( pressureStreamHandler)
    }

    private fun tearDownChannel(){
        methodChannel!!.setMethodCallHandler(null)
        pressureChannel!!.setStreamHandler(null)
    }
}
