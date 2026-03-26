import datetime
from django.core.management.base import BaseCommand
from tasks.models import Task

class Command(BaseCommand):
    help = 'Seeds the database with sample tasks for testing'

    def handle(self, *args, **kwargs):
        self.stdout.write('Deleting existing tasks...')
        Task.objects.all().delete()

        self.stdout.write('Seeding new tasks...')

        # 1. Create independent tasks
        task_a = Task.objects.create(
            title="Design System Review",
            description="Review the new Material 3 design tokens and component library.",
            due_date=datetime.date.today() + datetime.timedelta(days=2),
            status="Done"
        )

        task_b = Task.objects.create(
            title="Setup PostgreSQL",
            description="Configure the production database and run initial migrations.",
            due_date=datetime.date.today() + datetime.timedelta(days=1),
            status="In Progress"
        )

        # 2. Create a "Blocked" Task (Blocked by Task B which is In Progress)
        Task.objects.create(
            title="API Load Testing",
            description="Run Locust scripts to test endpoint stability. This is blocked by DB setup.",
            due_date=datetime.date.today() + datetime.timedelta(days=5),
            status="To-Do",
            blocked_by=task_b
        )

        # 3. Create a "Resolved" Blocked Task (Blocked by Task A which is Done)
        # This one should NOT be greyed out in your Flutter UI
        Task.objects.create(
            title="Frontend Integration",
            description="Connect the task list screen to the backend. Blocker is already finished.",
            due_date=datetime.date.today() + datetime.timedelta(days=3),
            status="To-Do",
            blocked_by=task_a
        )

        # 4. A standard To-Do task
        Task.objects.create(
            title="Write Documentation",
            description="Draft the README and technical overview for the hand-off.",
            due_date=datetime.date.today() + datetime.timedelta(days=7),
            status="To-Do"
        )

        # 5. A task with an upcoming deadline for search testing
        Task.objects.create(
            title="Client Presentation",
            description="Walk through the final app build with the stakeholders.",
            due_date=datetime.date.today() + datetime.timedelta(days=10),
            status="To-Do"
        )

        self.stdout.write(self.style.SUCCESS('Successfully seeded 6 tasks.'))