package com.example.manejemen_barang_hilanh

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.view.WindowManager
import android.view.View

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Menghilangkan FLAG_SECURE untuk mengizinkan screenshot
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
    
    override fun onResume() {
        super.onResume()
        // Pastikan FLAG_SECURE tetap dihilangkan setelah resume
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
    
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            // Pastikan FLAG_SECURE tetap dihilangkan ketika window mendapat fokus
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
