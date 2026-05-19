package com.hdseo.elementaryschoolbook.data

import kotlinx.serialization.Serializable
import java.io.File

@Serializable
data class Book(
    val id: String,
    val title: String,
    val linkTitle: String,
    val grade: Int,
    val subject: String,
    val viewPageId: String,
    val viewSection: String = "교과서",
    val lastDownloaded: Long? = null,   // epoch millis
    val publisher: String = "미래엔",
    val isArchived: Boolean = false,
    val catalogKey: String = id
) {
    fun pdfFile(filesDir: File): File = File(filesDir, "$id.pdf")
    fun annotationFile(filesDir: File): File = File(filesDir, "$id.json")
    fun isDownloaded(filesDir: File): Boolean = pdfFile(filesDir).exists()

    val supplementLabel: String? get() = when (viewSection) {
        "수학익힘"  -> "익힘"
        "실험관찰"  -> "실험관찰"
        else       -> null
    }
}
