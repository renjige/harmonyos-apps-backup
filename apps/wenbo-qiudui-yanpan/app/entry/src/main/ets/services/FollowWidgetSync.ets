import { formBindingData, formProvider } from '@kit.FormKit'
import { FollowWidgetPayload } from '../models/MatchModels'
import { FollowWidgetStore } from './FollowWidgetStore'

export class FollowWidgetSync {
  static async push(data: FollowWidgetPayload): Promise<void> {
    await FollowWidgetStore.reload()
    await FollowWidgetStore.writeSnapshot(data)
    const ids = await FollowWidgetStore.formIds()
    for (const id of ids) {
      if (id.length === 0) {
        continue
      }
      try {
        await formProvider.updateForm(id, formBindingData.createFormBindingData(data))
      } catch {
        await FollowWidgetStore.forgetFormId(id)
      }
    }
  }
}
