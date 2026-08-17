package com.example.fitquest

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class FitQuestWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.fitquest_widget)

            // Streak
            val streak = widgetData.getInt("streak", 12)
            views.setTextViewText(R.id.widget_streak_text, "🔥 $streak ${if (streak == 1) "Day" else "Days"}")

            // Completed Quests Count
            val completedQuests = widgetData.getInt("completed_quests", 0)
            val totalQuests = widgetData.getInt("total_quests", 5).coerceAtLeast(1)
            views.setTextViewText(R.id.widget_quest_progress_text, "$completedQuests / $totalQuests")

            // Progress Bar
            val progressPercent = ((completedQuests.toFloat() / totalQuests.toFloat()) * 100).toInt().coerceIn(0, 100)
            views.setProgressBar(R.id.widget_quest_progress_bar, 100, progressPercent, false)

            // Next Incomplete Quest Title & Description
            val nextQuestTitle = widgetData.getString("next_quest_title", null)
            val nextQuestSubtitle = widgetData.getString("next_quest_subtitle", null)

            if (!nextQuestTitle.isNullOrEmpty()) {
                views.setTextViewText(R.id.widget_next_quest_title, nextQuestTitle)
                views.setTextViewText(
                    R.id.widget_next_quest_subtitle,
                    nextQuestSubtitle ?: "Daily Quest Active"
                )
            } else {
                views.setTextViewText(R.id.widget_next_quest_title, "🏃 Morning Warrior")
                views.setTextViewText(R.id.widget_next_quest_subtitle, "20m physical activity • +100 XP")
            }

            // Level & XP
            val level = widgetData.getInt("level", 7)
            val xp = widgetData.getInt("xp", 1820)
            views.setTextViewText(R.id.widget_level_text, "⭐ Level $level")
            views.setTextViewText(R.id.widget_xp_text, "$xp XP")

            // On-click launch FitQuest MainActivity
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_MAIN
                addCategory(Intent.CATEGORY_LAUNCHER)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            Log.e("FitQuestWidget", "Error updating widget: ${e.message}", e)
        }
    }
}
