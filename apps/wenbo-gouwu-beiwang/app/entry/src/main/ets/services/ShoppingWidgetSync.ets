import { formBindingData, formProvider } from '@kit.FormKit'
import { ShoppingLocalStore } from './ShoppingLocalStore'
import { WidgetPayload } from '../models/ShoppingModels'

export class ShoppingWidgetSync {
  static async push(): Promise<void> {
    const snap: WidgetPayload = ShoppingLocalStore.widgetPayload()
    const ids = await ShoppingLocalStore.formIds()
    for (const id of ids) {
      if (id.length === 0) {
        continue
      }
      try {
        await formProvider.updateForm(id, formBindingData.createFormBindingData(snap))
      } catch {
        await ShoppingLocalStore.forgetFormId(id)
      }
    }
  }
}
