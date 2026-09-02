import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ChecklistItem } from '../../models/LifeModels'
import { LifeStorePhase3 } from '../../services/LifeStorePhase3'
import { AchievementService } from '../../services/AchievementService'
import { ChecklistSection } from './ChecklistSection'

@Component
export struct ChecklistSheet {
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  @State items: ChecklistItem[] = []
  @State newTitle: string = ''
  @State newCategory: string = 'want_done'
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await LifeStorePhase3.loadChecklist()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async addItem(): Promise<void> {
    const title = this.newTitle.trim()
    if (title.length < 2) {
      this.showToast('至少 2 字')
      return
    }
    const item = ChecklistItem.createNew(title, this.newCategory)
    await LifeStorePhase3.saveChecklistItem(item)
    this.newTitle = ''
    this.onChanged()
    await this.reload()
    this.showToast('已添加')
  }

  private async toggleStatus(id: string): Promise<void> {
    for (const c of this.items) {
      if (c.id === id) {
        if (c.status === 'pending') {
          c.status = 'active'
        } else if (c.status === 'active') {
          c.status = 'done'
        } else {
          c.status = 'pending'
        }
        await LifeStorePhase3.saveChecklistItem(c)
        await AchievementService.checkAndUnlock()
        this.onChanged()
        await this.reload()
        return
      }
    }
  }

  private async deleteItem(id: string): Promise<void> {
    await LifeStorePhase3.deleteChecklistItem(id)
    this.onChanged()
    await this.reload()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('人生清单')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('关闭')
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.onClose() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        Row({ space: Theme.space.s2 }) {
          TextInput({ text: this.newTitle, placeholder: '想完成的事…' })
            .layoutWeight(1)
            .onChange((v: string): void => { this.newTitle = v })
          AppButton({ label: '添加', variant: 'primary', onTap: (): void => { void this.addItem() } })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Scroll() {
          ChecklistSection({
            items: this.items,
            onToggleStatus: (id: string): void => { void this.toggleStatus(id) },
            onDelete: (id: string): void => { void this.deleteItem(id) }
          })
            .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s2 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
