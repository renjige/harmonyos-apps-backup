import { FormExtensionAbility, formBindingData } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';

class WidgetPayload {
  title: string = '今日约定'
  summary: string = ''
  count: string = '0'
}

export default class AppointmentWidgetAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const data = new WidgetPayload();
    data.title = '今日约定';
    data.summary = '打开应用查看详情';
    data.count = '0';
    return formBindingData.createFormBindingData(data);
  }
}
