from rest_framework import serializers
from .models import Task

class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ['id', 'title', 'description', 'due_date', 'status', 'blocked_by']

    def validate_blocked_by(self, value):
        if value and value.status == 'Done':
            raise serializers.ValidationError("Cannot be blocked by a task that is already 'Done'.")
        return value