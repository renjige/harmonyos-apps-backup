import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { ChecklistRow } from '../components/wander/ChecklistRow'
import { CheckItem } from '../models/WanderModels'
import { WanderDetailNav } from '../services/WanderDetailNav'
import { WanderLocalStore } from '../services/WanderLocalStore'

@Component
export struct ChecklistPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: CheckItem[] = []
  @State draft: string = ''
  @State pendingRemove: string = ''
  @State paint: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await WanderLocalStore.loadChecks()
  }

  private bump(): void {
    this.paint += 1
  }

  private async persist(): Promise<void> {
    await WanderLocalStore.saveChecks(this.items)
  }

  private async toggle(id: string): Promise<void> {
    const next: CheckItem[] = []
    for (const it of this.items) {
      const copy = new CheckItem()
      copy.id = it.id
      copy.label = it.label
      copy.done = it.id === id ? !it.done : it.done
      next.push(copy)
    }
    this.items = next
    this.bump()
    await this.persist()
  }

  private async remove(id: string): Promise<void> {
    const next: CheckItem[] = []
    for (const it of this.items) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    this.items = next
    this.bump()
    await this.persist()
  }

  private async addItem(): Promise<void> {
    const label = this.draft.trim()
    if (label.length === 0) {
      return
    }
    const it = new CheckItem()
    it.id = WanderLocalStore.newId('ck')
    it.label = label
    it.done = false
    const next: CheckItem[] = []
    for (const old of this.items) {
      next.push(old)
    }
    next.push(it)
    this.items = next
    this.draft = ''
    this.bump()
    await this.persist()
  }

  private async clearDone(): Promise<void> {
    const next: CheckItem[] = []
    for (const it of this.items) {
      if (!it.done) {
        next.push(it)
      }
    }
    this.items = next
    this.bump()
    await this.persist()
  }

  build() {
    DetailShell({ title: '出行清单', contentKey: `${this.paint}`, onClose: () => WanderDetailNav.close() }) {
      Column({ space: 12 }) {
        Text('勾选一件，夏天就轻一点。')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        ForEach(this.items, (it: CheckItem) => {
          Column({ space: 8 }) {
            ChecklistRow({
              label: it.label,
              done: it.done,
              onToggle: (): void => { void this.toggle(it.id) },
              onRemove: (): void => {
                this.pendingRemove = it.id
                this.bump()
              }
            })
            if (this.pendingRemove === it.id) {
              Row({ space: 8 }) {
                Text('删掉这一件？')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .layoutWeight(1)
                AppButton({
                  label: '取消',
                  variant: 'ghost',
                  onTap: (): void => { this.pendingRemove = ''; this.bump() }
                }).width(72)
                AppButton({
                  label: '删除',
                  variant: 'danger',
                  onTap: (): void => {
                    this.pendingRemove = ''
                    void this.remove(it.id)
                  }
                }).width(72)
              }
              .width('100%')
            }
          }
          .width('100%')
        }, (it: CheckItem) => `${it.id}_${it.done ? '1' : '0'}`)
        Row({ space: 8 }) {
          TextInput({ text: this.draft, placeholder: '再加一件要带的' })
            .onChange((v: string) => { this.draft = v })
            .layoutWeight(1)
          AppButton({ label: '添加', variant: 'secondary', onTap: (): void => { void this.addItem() } }).width(88)
        }
        .width('100%')
        AppButton({ label: '清空已完成', variant: 'ghost', onTap: (): void => { void this.clearDone() } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
