import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { FilterChip, WrongItem } from '../../models/MathModels'
import { MathBizService } from '../../services/MathBizService'
import { MathLocalStore } from '../../services/MathLocalStore'

@Component
export struct WrongBookOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('mathHomeTick') @Watch('onTick') dataTick: number = 0
  @Prop bookKind: string = 'wrong'
  @Prop title: string = '我的错题'
  @Prop emptyHint: string = '目前没有需要复习的题目'
  @State items: WrongItem[] = []
  @State filterId: string = 'all'
  @State chips: FilterChip[] = []
  @State noteId: string = ''
  @State noteDraft: string = ''
  onClose: () => void = () => {}
  onRetryOne: (item: WrongItem) => void = (_item: WrongItem) => {}
  onRetryAll: () => void = () => {}

  aboutToAppear(): void {
    this.chips = WrongBookOverlay.tagChips()
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private static pushChip(out: FilterChip[], id: string, label: string): void {
    const c = new FilterChip()
    c.id = id
    c.label = label
    out.push(c)
  }

  private static tagChips(): FilterChip[] {
    const out: FilterChip[] = []
    WrongBookOverlay.pushChip(out, 'all', '全部')
    WrongBookOverlay.pushChip(out, '口算', '口算')
    WrongBookOverlay.pushChip(out, '应用题', '应用题')
    WrongBookOverlay.pushChip(out, '口诀', '口诀')
    WrongBookOverlay.pushChip(out, '数感', '数感')
    return out
  }

  private source(): WrongItem[] {
    return this.bookKind === 'fav' ? MathLocalStore.snapshot().favorites : MathLocalStore.snapshot().wrongs
  }

  private reload(): void {
    const next: WrongItem[] = []
    for (const it of this.source()) {
      if (this.filterId === 'all' || it.tag === this.filterId) {
        next.push(it)
      }
    }
    this.items = next
  }

  private setFilter(id: string): void {
    this.filterId = id
    this.reload()
  }

  private async saveNote(id: string): Promise<void> {
    await MathBizService.saveWrongNote(id, this.noteDraft)
    this.noteId = ''
    this.noteDraft = ''
    this.reload()
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44).height(44).justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text(this.title)
          .fontSize(Theme.type.title3).fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Blank().width(44)
      }
      .width('100%').padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.chips, (c: FilterChip) => {
          Text(c.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.filterId === c.id ? '#FFFFFF' : Theme.colors().textPrimary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(this.filterId === c.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.setFilter(c.id))
        }, (c: FilterChip) => c.id)
      }
      .width('100%')
      .padding({ left: Theme.space.s5, right: Theme.space.s5 })

      if (this.items.length === 0) {
        Column() {
          AppEmpty({ title: '太棒啦！', description: this.emptyHint })
        }
        .layoutWeight(1).justifyContent(FlexAlign.Center).width('100%')
      } else {
        List() {
          ForEach(this.items, (item: WrongItem) => {
            ListItem() {
              Column({ space: Theme.space.s3 }) {
                Text(item.expression)
                  .fontSize(Theme.type.title3).fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                if (item.tag.length > 0) {
                  Text(item.tag)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width('100%')
                }
                Text(`上次答案：${item.userAnswer}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text(`正确答案：${item.correctAnswer}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                if (item.note.length > 0) {
                  Text(item.note)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                if (this.bookKind === 'wrong' && this.noteId === item.id) {
                  TextInput({ text: this.noteDraft, placeholder: '写一句提醒，如进位要看清楚' })
                    .width('100%').height(40)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .onChange((v: string) => { this.noteDraft = v })
                  AppButton({
                    label: '保存备注',
                    variant: 'secondary',
                    onTap: (): void => { void this.saveNote(item.id) }
                  })
                } else if (this.bookKind === 'wrong') {
                  Text('写备注')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .onClick(() => {
                      this.noteId = item.id
                      this.noteDraft = item.note
                    })
                }
                AppButton({
                  label: '再算一次',
                  variant: 'secondary',
                  onTap: () => this.onRetryOne(item)
                })
              }
              .width('100%').padding(Theme.space.s5)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .margin({ bottom: Theme.space.s3 })
            }
          }, (item: WrongItem) => item.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.s5, right: Theme.space.s5, top: Theme.space.s3 })
        .scrollBar(BarState.Off)
        Column() {
          AppButton({ label: '全部再算一次', onTap: () => this.onRetryAll() })
        }
        .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s7 })
      }
    }
    .width('100%').height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
