import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { ResearchPin, ResearchStore } from '../services/ResearchStore'
import { TeamNoteItem, TeamNoteStore } from '../services/TeamNoteStore'
import { DetailNav } from '../services/DetailNav'
import { SportsBizService } from '../services/SportsBizService'

class NoteRow {
  teamId: string = ''
  teamTitle: string = ''
  text: string = ''
}

@Component
export struct ResearchFolderPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onClose: () => void = () => {}
  @State pins: ResearchPin[] = []
  @State notes: NoteRow[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.pins = ResearchStore.list()
    const raw: TeamNoteItem[] = TeamNoteStore.listAll()
    const teams = await SportsBizService.loadTeams('', false)
    const next: NoteRow[] = []
    for (const n of raw) {
      const row = new NoteRow()
      row.teamId = n.teamId
      row.text = n.text
      row.teamTitle = n.teamId
      for (const t of teams) {
        if (t.id === n.teamId) {
          row.teamTitle = t.title
          break
        }
      }
      next.push(row)
    }
    this.notes = next
  }

  private openPin(pin: ResearchPin): void {
    if (pin.kind === 'team' || pin.kind === 'news') {
      let teamId = pin.id
      if (pin.kind === 'news' && pin.id.indexOf('news-') === 0) {
        teamId = pin.id.substring(5)
      }
      DetailNav.openTeam(teamId)
      return
    }
    if (pin.kind === 'match') {
      DetailNav.openMatch(pin.id)
    }
  }

  private async removePin(pin: ResearchPin): Promise<void> {
    await ResearchStore.remove(pin.kind, pin.id)
    this.pins = ResearchStore.list()
    this.showToast('已移出收藏夹')
  }

  private kindLabel(kind: string): string {
    if (kind === 'match') {
      return '重点比赛'
    }
    if (kind === 'news') {
      return '资讯'
    }
    return '球队分析'
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Column({ space: 2 }) {
            Text('研判收藏夹')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text('本机研究库：收藏与观察笔记，新用户为空')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s3 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('收藏内容')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            if (this.pins.length === 0) {
              AppEmpty({
                title: '收藏夹是空的',
                description: '在球队或比赛详情把内容加入研究库'
              })
            } else {
              ForEach(this.pins, (pin: ResearchPin) => {
                Column({ space: 6 }) {
                  Text(this.kindLabel(pin.kind))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                  Text(pin.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  if (pin.subtitle.length > 0) {
                    Text(pin.subtitle)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                      .width('100%')
                  }
                  Row({ space: Theme.space.s3 }) {
                    Column() {
                      AppButton({
                        label: '打开',
                        variant: 'secondary',
                        onTap: (): void => { this.openPin(pin) }
                      })
                    }
                    .layoutWeight(1)
                    Column() {
                      AppButton({
                        label: '移出',
                        variant: 'secondary',
                        onTap: (): void => { void this.removePin(pin) }
                      })
                    }
                    .layoutWeight(1)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
              }, (pin: ResearchPin) => `pin-${pin.kind}-${pin.id}`)
            }

            Text('观察笔记')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            if (this.notes.length === 0) {
              AppEmpty({
                title: '还没有笔记',
                description: '在球队详情写下你的研判观点后会出现在这里'
              })
            } else {
              ForEach(this.notes, (row: NoteRow) => {
                Column({ space: 6 }) {
                  Text(row.teamTitle)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(row.text)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick((): void => { DetailNav.openTeam(row.teamId) })
              }, (row: NoteRow) => `note-${row.teamId}`)
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
