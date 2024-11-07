public class NintexTaskTriggerHandler {
public static void onBeforeInsert(List<Task> newTasks) {
        for(Task task : newTasks){
            String taskTitle = task.Subject;
            if(taskTitle.containsIgnoreCase('&amp;')){
                task.Subject = taskTitle.replaceAll('amp;', '');
                taskTitle = task.Subject;
            }
            if(taskTitle.containsIgnoreCase('&quot;')){
                task.Subject = taskTitle.replaceAll('&quot;', '\"');
                taskTitle = task.Subject;
            }
            if(taskTitle.containsIgnoreCase('&#39;')){
                task.Subject = taskTitle.replaceAll('&#39;', '\'');
                taskTitle = task.Subject;
            }
            if(taskTitle.containsIgnoreCase('&lt;')){
                task.Subject = taskTitle.replaceAll('&lt;', '<');
                taskTitle = task.Subject;
            }
            if(taskTitle.containsIgnoreCase('&gt;')){
                task.Subject = taskTitle.replaceAll('&gt;', '>');
            }
        }
    }
}