import { FormExtensionAbility, formBindingData } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';

class MatchWidgetPayload {
  title: string = '关注比赛'
  summary: string = ''
  count: string = '0'
}

export default class MatchWidgetAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const data = new MatchWidgetPayload();
    data.title = '关注比赛';
    data.summary = '打开赛事纵览查看详情';
    data.count = '0';
    return formBindingData.createFormBindingData(data);
  }
}
