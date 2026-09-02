import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AthleteItem, ScoutNote } from '../models/StarModels'
import { StarBizService } from '../services/StarBizService'
import { StarDetailNav } from '../services/StarDetailNav'
import { ScoutNoteService } from '../services/ScoutNoteService'

class ScoreOpt {
  value: number = 3
  label: string = '3'
}

@Component
export struct ScoutNotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop athleteId: string = ''
  @Prop @Watch('onNavTokenChange') navToken: number = 0
  @StorageLink('scoutTick') scoutTick: number = 0
  @State notes: ScoutNote[] = []
  @State athletes: AthleteItem[] = []
  @State loading: boolean = true
  @State editId: string = ''
  @State editTitle: string = ''
  @State editSport: string = ''
  @State techScore: number = 3
  @State formScore: number = 3
  @State noteText: string = ''
  @State toastText: string = ''
  @State picking: boolean = false
  private scores: ScoreOpt[] = ScoutNotesPage.buildScores()

  private static buildScores(): ScoreOpt[] {
    const out: ScoreOpt[] = []
    let i = 1
    while (i <= 5) {
      const o = new ScoreOpt()
      o.value = i
      o.label = `${i}`
      out.push(o)
      i += 1
    }
    return out
  }

  aboutToAppear(): void {
    void this.reload()
  }

  onNavTokenChange(): void {
    if (this.athleteId.length > 0) {
      this.beginEdit(this.athleteId)
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.notes = ScoutNoteService.list()
    this.athletes = await StarBizService.loadAthletes('', false)
    if (this.athleteId.length > 0) {
      this.beginEdit(this.athleteId)
    }
    this.loading = false
  }

  private beginEdit(id: string): void {
    this.editId = id
    this.picking = false
    const exist = ScoutNoteService.find(id)
    if (exist !== undefined) {
      this.editTitle = exist.title
      this.editSport = exist.sport
      this.techScore = exist.techScore
      this.formScore = exist.formScore
      this.noteText = exist.note
      return
    }
    this.techScore = 3
    this.formScore = 3
    this.noteText = ''
    this.editTitle = id
    this.editSport = ''
    for (const a of this.athletes) {
      if (a.id === id) {
        this.editTitle = a.title
        this.editSport = a.sportLabel()
        break
      }
    }
  }

  private async saveNote(): Promise<void> {
    if (this.editId.length === 0) {
      this.showToast('请先选择球星')
      return
    }
    const n = new ScoutNote()
    n.athleteId = this.editId
    n.title = this.editTitle
    n.sport = this.editSport
    n.techScore = this.techScore
    n.formScore = this.formScore
    n.note = this.noteText
    await ScoutNoteService.save(n)
    this.notes = ScoutNoteService.list()
    this.showToast('球探笔记已保存')
  }

  private async dropNote(id: string): Promise<void> {
    await ScoutNoteService.remove(id)
    this.notes = ScoutNoteService.list()
    if (this.editId === id) {
      this.editId = ''
      this.noteText = ''
    }
    this.showToast('已删除笔记')
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { StarDetailNav.close() })
          Text('球探笔记')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.loading) {
          AppLoading({ label: '加载笔记…' }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Text('给关注的球星打分并写下观察，形成你自己的球探档案')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')

              AppButton({
                label: this.editId.length > 0 ? `正在记录：${this.editTitle}` : '选择球星写笔记',
                variant: 'secondary',
                onTap: (): void => { this.picking = !this.picking }
              })

              if (this.picking) {
                ForEach(this.athletes.slice(0, 12), (a: AthleteItem) => {
                  Text(`${a.title} · ${a.sportLabel()}`)
                    .fontSize(Theme.type.callout)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                    .padding(Theme.space.s3)
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.lg)
                    .onClick((): void => { this.beginEdit(a.id) })
                }, (a: AthleteItem) => a.id)
              }

              if (this.editId.length > 0) {
                Text('技术评分')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Row({ space: 8 }) {
                  ForEach(this.scores, (opt: ScoreOpt) => {
                    Text(opt.label)
                      .fontSize(Theme.type.subhead)
                      .fontColor(this.techScore === opt.value ?
                        Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .backgroundColor(this.techScore === opt.value ?
                        Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.techScore = opt.value })
                  }, (opt: ScoreOpt) => `t${opt.value}`)
                }
                Text('状态评分')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Row({ space: 8 }) {
                  ForEach(this.scores, (opt: ScoreOpt) => {
                    Text(opt.label)
                      .fontSize(Theme.type.subhead)
                      .fontColor(this.formScore === opt.value ?
                        Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .backgroundColor(this.formScore === opt.value ?
                        Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.formScore = opt.value })
                  }, (opt: ScoreOpt) => `f${opt.value}`)
                }
                TextInput({ text: this.noteText, placeholder: '写下观察：节奏、位置、近期状态…' })
                  .width('100%')
                  .height(80)
                  .onChange((v: string): void => { this.noteText = v })
                AppButton({
                  label: '保存球探笔记',
                  onTap: (): void => { void this.saveNote() }
                })
              }

              Text(`已保存 ${this.notes.length} 条`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              if (this.notes.length === 0) {
                AppEmpty({ title: '暂无笔记', description: '选择球星后打分并保存，即形成个人球探档案' })
              } else {
                ForEach(this.notes, (n: ScoutNote) => {
                  Column({ space: 6 }) {
                    Text(n.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text(`${n.sport} · ${n.scoreLine()}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .width('100%')
                    if (n.note.length > 0) {
                      Text(n.note)
                        .fontSize(Theme.type.footnote)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                        .width('100%')
                    }
                    Row({ space: Theme.space.s2 }) {
                      AppButton({
                        label: '继续编辑',
                        variant: 'secondary',
                        onTap: (): void => { this.beginEdit(n.athleteId) }
                      })
                        .layoutWeight(1)
                      AppButton({
                        label: '看资料',
                        variant: 'secondary',
                        onTap: (): void => { StarDetailNav.openAthlete(n.athleteId) }
                      })
                        .layoutWeight(1)
                      AppButton({
                        label: '删除',
                        variant: 'secondary',
                        onTap: (): void => { void this.dropNote(n.athleteId) }
                      })
                        .layoutWeight(1)
                    }
                    .width('100%')
                  }
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.xl)
                  .border({ width: 1, color: Theme.colors().strokeHairline })
                }, (n: ScoutNote) => n.athleteId)
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
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

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
      }
    }
    .width('100%')
    .height('100%')
  }
}
