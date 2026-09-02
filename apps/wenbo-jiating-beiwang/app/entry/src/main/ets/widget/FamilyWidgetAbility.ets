import { FormExtensionAbility, formBindingData } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';

class WidgetPayload {
  title: string = '今日家庭';
  progress: string = '';
}

export default class FamilyWidgetAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const data = new WidgetPayload();
    data.title = '今日家庭';
    data.progress = '打开应用查看进度';
    return formBindingData.createFormBindingData(data);
  }
}
