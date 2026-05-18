package com.hdseo.elementaryschoolbook

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.viewmodel.compose.viewModel
import com.hdseo.elementaryschoolbook.ui.BookListScreen
import com.hdseo.elementaryschoolbook.ui.theme.ElementarySchoolBookTheme
import com.hdseo.elementaryschoolbook.viewmodel.BookStoreViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            ElementarySchoolBookTheme {
                val viewModel: BookStoreViewModel = viewModel()
                BookListScreen(viewModel = viewModel)
            }
        }
    }
}
