import { FormExtensionAbility, formBindingData, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { FollowWidgetStore } from '../services/FollowWidgetStore';
import { FollowWidgetPayload } from '../models/MatchModels';

export default class TeamWidgetAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const formId = this.readFormId(want);
    if (formId.length > 0) {
      void this.refresh(formId);
    }
    return formBindingData.createFormBindingData(FollowWidgetStore.emptyPayload());
  }

  onUpdateForm(formId: string): void {
    void this.refresh(formId);
  }

  onRemoveForm(formId: string): void {
    void this.forget(formId);
  }

  private async forget(formId: string): Promise<void> {
    try {
      await FollowWidgetStore.init(this.context);
      await FollowWidgetStore.forgetFormId(formId);
    } catch {
    }
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
      await FollowWidgetStore.init(this.context);
      await FollowWidgetStore.rememberFormId(formId);
      const snap: FollowWidgetPayload = await FollowWidgetStore.readSnapshot(this.context);
      await formProvider.updateForm(formId, formBindingData.createFormBindingData(snap));
    } catch {
    }
  }
}
