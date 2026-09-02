import { FormExtensionAbility, formBindingData } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';

class WidgetPayload {
  title: string = '我的关注'
  summary: string = ''
  count: string = '0'
}

export default class StarWidgetAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const data = new WidgetPayload();
    data.title = '我的关注';
    data.summary = '打开应用查看关注球星与赛事';
    data.count = '0';
    return formBindingData.createFormBindingData(data);
  }
}
