package com.example.travia

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.travia/material_picker"
    private val requestCode = 4107
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "pickMaterial") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (pendingResult != null) {
                    result.error("picker_busy", "Já existe uma seleção em andamento.", null)
                    return@setMethodCallHandler
                }
                pendingResult = result
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "*/*"
                    putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("application/pdf", "image/png", "image/jpeg"))
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
                }
                try {
                    startActivityForResult(intent, requestCode)
                } catch (error: Exception) {
                    pendingResult = null
                    result.error("picker_unavailable", "Não foi possível abrir o seletor de arquivos.", error.message)
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != this.requestCode) return
        val result = pendingResult ?: return
        pendingResult = null
        Log.d("TraviaPicker", "Resultado do seletor: code=$resultCode, hasData=${data?.data != null}")
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }
        try {
            result.success(copySelectedContent(data.data!!))
        } catch (error: Exception) {
            Log.e("TraviaPicker", "Falha ao copiar conteúdo selecionado", error)
            result.error("copy_failed", "Não foi possível copiar o arquivo selecionado.", error.message)
        }
    }

    private fun copySelectedContent(uri: Uri): Map<String, Any> {
        Log.d("TraviaPicker", "Iniciando cópia: scheme=${uri.scheme}, authority=${uri.authority}")
        try {
            contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
        } catch (_: SecurityException) {
            // A cópia imediata não depende da permissão persistente.
        }
        val name = queryDisplayName(uri) ?: "material.pdf"
        val safeName = name.replace(Regex("[^a-zA-Z0-9._-]"), "_")
        val target = File(cacheDir, "travia-material-picker/${System.currentTimeMillis()}_$safeName")
        target.parentFile?.mkdirs()
        val input = contentResolver.openInputStream(uri)
            ?: throw IllegalStateException("ContentResolver não abriu o arquivo selecionado.")
        input.use { source ->
            target.outputStream().buffered(1024 * 1024).use { output ->
                source.copyTo(output, 1024 * 1024)
            }
        }
        val size = target.length()
        Log.d("TraviaPicker", "Cópia concluída: bytes=$size")
        if (size == 0L) {
            target.delete()
            throw IllegalArgumentException("O arquivo selecionado está vazio.")
        }
        return mapOf("name" to name, "path" to target.absolutePath, "size" to size)
    }

    private fun queryDisplayName(uri: Uri): String? {
        contentResolver.query(uri, arrayOf("_display_name"), null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) return cursor.getString(0)
        }
        return uri.lastPathSegment?.substringAfterLast('/')?.ifBlank { null }
    }
}
