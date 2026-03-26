from django.contrib import admin
from .models import Task

@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    # Fields to display in the list view
    list_display = ('title', 'status', 'due_date', 'blocked_by', 'created_at')
    
    # Add filters to the right sidebar
    list_filter = ('status', 'due_date')
    
    # Add a search bar for the title and description
    search_fields = ('title', 'description')
    
    # Organize the detail view
    fieldsets = (
        ('Core Information', {
            'fields': ('title', 'description', 'status', 'due_date')
        }),
        ('Dependencies', {
            'fields': ('blocked_by',),
            'description': 'Select a task that must be completed before this one.'
        }),
    )