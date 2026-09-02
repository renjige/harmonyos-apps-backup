import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { SolidButton } from '../design-system/SolidButton'
import { HubShell } from './HubShell'
import { MoveDetailPane } from '../detail/MoveDetailPane'
import { MoveFormOverlay } from './MoveFormOverlay'
import { MoveDraft, MoveItem } from '../../models/TrainingModels'
import { PracticeHubStore } from '../../services/PracticeHubStore'
import { PracticeService } from '../../services/PracticeService'
import { VitalityService } from '../../services/VitalityService'
import { DataRefresh } from '../../services/DataRefresh'

@Component
export struct MoveHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onMoveEpoch') dataEpoch: number = 0
  @State items: MoveItem[] = []
  @State filter: string = '全部'
  @State detailId: string = ''
  @State showForm: boolean = false
  @State draft: MoveDraft = new MoveDraft()
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onMoveEpoch(): void {
    this.reload()
  }

  private reload(): void {
    this.items = PracticeHubStore.listMoves()
  }

  private visible(): MoveItem[] {
    if (this.filter === '全部') {
      return this.items
    }
    const out: MoveItem[] = []
    for (const m of this.items) {
      if (this.filter === '收藏') {
        if (m.favorited === '1') {
          out.push(m)
        }
      } else if (m.category === this.filter) {
        out.push(m)
      }
    }
    return out
  }

  private async submitMove(): Promise<void> {
    if (this.draft.title.trim().length === 0) {
      return
    }
    await PracticeHubStore.saveMove(PracticeService.createMove(this.draft))
    await VitalityService.award(3)
    this.showForm = false
    this.draft = new MoveDraft()
    DataRefresh.bump()
    this.reload()
  }

  build() {
    if (this.detailId.length > 0) {
      MoveDetailPane({
        moveId: this.detailId,
        onClose: (): void => {
          this.detailId = ''
          this.reload()
        },
        onChanged: (): void => { this.reload() }
      })
    } else if (this.showForm) {
      MoveFormOverlay({
        draft: this.draft,
        onClose: (): void => { this.showForm = false },
        onSubmit: (): void => { void this.submitMove() },
        onDraftChange: (d: MoveDraft): void => { this.draft = d }
      })
    } else {
      HubShell({
        title: '动作图鉴',
        onClose: (): void => { this.onClose() },
        body: (): void => { this.Body() }
      })
    }
  }

  @Builder
  Body() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(['全部', '热身', '拉伸', '力量', '平衡', '放松', '收藏'], (cat: string) => {
        Text(cat)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.filter === cat ? '#FFFFFF' : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.filter === cat ? Theme.primaryButtonFill() : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .margin({ right: 8, bottom: 8 })
          .onClick((): void => { this.filter = cat })
      }, (cat: string) => cat)
    }
    .width('100%')

    Column() {
      SolidButton({
        label: '收藏新动作',
        tone: 'primary',
        onTap: (): void => { this.showForm = true }
      })
    }
    .width('100%')
    .onClick((): void => { this.showForm = true })

    if (this.visible().length === 0) {
      AppEmpty({
        title: '动作库是空的',
        description: '把常用热身、力量、柔韧、放松动作存进来，训练前打开即可'
      })
    } else {
      ForEach(this.visible(), (m: MoveItem) => {
        Row() {
          Column({ space: 4 }) {
            Text(m.title)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text(m.category)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick((): void => { this.detailId = m.id })
      }, (m: MoveItem) => m.id)
    }
  }
}
