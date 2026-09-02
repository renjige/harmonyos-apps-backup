import { FormExtensionAbility, formBindingData, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { ShoppingLocalStore } from '../services/ShoppingLocalStore';
import { WidgetPayload } from '../models/ShoppingModels';

export default class ShoppingWidgetAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const formId = this.readFormId(want);
    if (formId.length > 0) {
      void this.refresh(formId);
    }
    const data = new WidgetPayload();
    data.title = '购物备忘';
    data.progress = '打开应用查看进度';
    data.remain = '';
    data.preview = '记下想买的，出门逐项勾选';
    return formBindingData.createFormBindingData(data);
  }

  onUpdateForm(formId: string): void {
    void this.refresh(formId);
  }

  onRemoveForm(formId: string): void {
    void ShoppingLocalStore.forgetFormId(formId);
  }

  private readFormId(want: Want): string {
    const params = want.parameters;
    if (params === undefined) {
      return '';
    }
    const raw = params[formInfo.FormParam.IDENTITY_KEY];
    if (typeof raw === 'string') {
      return raw;
    }
    return '';
  }

  private async refresh(formId: string): Promise<void> {
    try {
      await ShoppingLocalStore.init(this.context);
      await ShoppingLocalStore.rememberFormId(formId);
      const snap = await ShoppingLocalStore.readWidgetSnapshot(this.context);
      await formProvider.updateForm(formId, formBindingData.createFormBindingData(snap));
    } catch {
    }
  }
}
