import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { UserKnowledge, KnowledgeCategory } from '../../models/UserKnowledgeModels'
import { KnowledgeStore } from '../../services/KnowledgeStore'
import { ReviewStore } from '../../services/ReviewStore'
import { WanXiangNav } from '../../services/WanXiangNav'

@Component
export struct UserKnowledgeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: UserKnowledge = new UserKnowledge()
  onClose: () => void = () => {}
  onDataChanged: () => void = () => {}
  onShowToast: (msg: string) => void = () => {}
  @State confirmDelete: boolean = false

  private async addReview(): Promise<void> {
    const added = await ReviewStore.addKnowledge(this.item.id)
    if (added) {
      this.onShowToast('已加入复习队列')
      this.onDataChanged()
    } else {
      this.onShowToast('已在复习队列中')
    }
  }

  private async deleteItem(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.onShowToast('再次点击删除以确认')
      return
    }
    const ok = await KnowledgeStore.remove(this.item.id)
    if (ok) {
      this.onShowToast('已删除')
      this.onDataChanged()
      this.onClose()
    }
  }

  build() {
    DetailShell({
      title: '我的知识',
      onClose: (): void => this.onClose(),
      content: (): void => { this.bodyContent() },
      footer: (): void => { this.footerBar() }
    })
  }

  @Builder
  bodyContent() {
    if (this.item.id.length === 0) {
      Text('加载中…')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
    } else {
      Column({ space: Theme.space.s4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        Text(`${KnowledgeCategory.emojiOf(this.item.categoryKey)} ${KnowledgeCategory.labelOf(this.item.categoryKey)}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)

        AppCard({ title: '正文' }) {
          Text(this.item.body)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .lineHeight(26)
            .width('100%')
        }

        if (this.item.tags.length > 0) {
          Text(`标签：${this.item.tags}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
      }
      .width('100%')
    }
  }

  @Builder
  footerBar() {
    Column({ space: Theme.space.s2 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppButton({
            label: '编辑',
            variant: 'primary',
            onTap: (): void => {
              WanXiangNav.openEditor(this.item.id)
              this.onClose()
            }
          })
        }.layoutWeight(1)
        Column() {
          AppButton({
            label: '加入复习',
            variant: 'secondary',
            onTap: (): void => { void this.addReview() }
          })
        }.layoutWeight(1)
      }
      .width('100%')
      AppButton({
        label: this.confirmDelete ? '确认删除' : '删除',
        variant: 'secondary',
        onTap: (): void => { void this.deleteItem() }
      })
    }
    .width('100%')
  }
}
