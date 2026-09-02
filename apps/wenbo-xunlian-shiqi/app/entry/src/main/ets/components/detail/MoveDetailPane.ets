import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { SolidButton } from '../design-system/SolidButton'
import { DetailShell } from './DetailShell'
import { MoveDraft, MoveItem } from '../../models/TrainingModels'
import { PracticeHubStore } from '../../services/PracticeHubStore'
import { PracticeService } from '../../services/PracticeService'
import { FollowAlongService } from '../../services/FollowAlongService'
import { DataRefresh } from '../../services/DataRefresh'
import { MoveFormOverlay } from '../practice/MoveFormOverlay'

@Component
export struct MoveDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop moveId: string = ''
  @State item: MoveItem = new MoveItem()
  @State confirmDelete: boolean = false
  @State showEdit: boolean = false
  @State draft: MoveDraft = new MoveDraft()
  @State toast: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.load()
  }

  private load(): void {
    const found = PracticeHubStore.findMove(this.moveId)
    if (found !== null) {
      this.item = found
    }
  }

  private openEdit(): void {
    this.draft = PracticeService.toMoveDraft(this.item)
    this.showEdit = true
  }

  private async submitEdit(): Promise<void> {
    if (this.draft.title.trim().length === 0) {
      return
    }
    const next = PracticeService.createMove(this.draft)
    next.id = this.item.id
    next.createdAt = this.item.createdAt
    next.favorited = this.item.favorited
    await PracticeHubStore.saveMove(next)
    this.showEdit = false
    DataRefresh.bump()
    this.onChanged()
    this.load()
  }

  private async deleteMove(): Promise<void> {
    await PracticeHubStore.deleteMove(this.moveId)
    DataRefresh.bump()
    this.onChanged()
    this.onClose()
  }

  private async toggleFav(): Promise<void> {
    const next = PracticeService.toggleFavorite(this.item)
    await PracticeHubStore.saveMove(next)
    this.item = next
    DataRefresh.bump()
    this.onChanged()
  }

  private async addToFollow(): Promise<void> {
    const ok = await FollowAlongService.addToQueue(this.moveId)
    this.toast = ok ? '已加入跟练清单' : '已在清单中或已满 5 个'
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.showEdit) {
      MoveFormOverlay({
        draft: this.draft,
        formTitle: '编辑动作',
        onClose: (): void => { this.showEdit = false },
        onSubmit: (): void => { void this.submitEdit() },
        onDraftChange: (d: MoveDraft): void => { this.draft = d }
      })
    } else {
      DetailShell({
        title: '动作收藏',
        onClose: (): void => { this.onClose() },
        body: (): void => { this.BodyContent() },
        footer: (): void => { this.FooterActions() }
      })
    }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(15,23,42,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BodyContent() {
    Column({ space: 8 }) {
      Text(this.item.category)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandPrimary)
      Text(this.item.title)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)

    AppCard({ title: '训练目的' }) {
      Text(this.item.purpose.length > 0 ? this.item.purpose : '未填写目的。编辑后可记下这个动作想练什么。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
    }

    AppCard({ title: '推荐组合' }) {
      Text(this.item.combo.length > 0 ? this.item.combo : '未填写组合。可写成热身之后接哪个拉伸。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
    }

    AppCard({ title: '注意事项' }) {
      Text(this.item.tips.length > 0 ? this.item.tips : '未填写要点。编辑后可记下节奏、呼吸或注意事项。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
    }
  }

  @Builder
  FooterActions() {
    if (this.confirmDelete) {
      Text('确定从动作库删除？')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().danger)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Column() {
          SolidButton({
            label: '取消',
            tone: 'secondary',
            onTap: (): void => { this.confirmDelete = false }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { this.confirmDelete = false })
        Column() {
          SolidButton({
            label: '确认删除',
            tone: 'danger',
            onTap: (): void => { void this.deleteMove() }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { void this.deleteMove() })
      }
      .width('100%')
    } else {
      Column() {
        SolidButton({
          label: '加入跟练清单',
          tone: 'primary',
          onTap: (): void => { void this.addToFollow() }
        })
      }
      .width('100%')
      .onClick((): void => { void this.addToFollow() })
      Column() {
        SolidButton({
          label: this.item.favorited === '1' ? '取消收藏' : '收藏动作',
          tone: 'secondary',
          onTap: (): void => { void this.toggleFav() }
        })
      }
      .width('100%')
      .onClick((): void => { void this.toggleFav() })
      Column() {
        SolidButton({
          label: '编辑动作',
          tone: 'primary',
          onTap: (): void => { this.openEdit() }
        })
      }
      .width('100%')
      .onClick((): void => { this.openEdit() })
      Column() {
        SolidButton({
          label: '删除动作',
          tone: 'secondary',
          onTap: (): void => { this.confirmDelete = true }
        })
      }
      .width('100%')
      .onClick((): void => { this.confirmDelete = true })
    }
  }
}
