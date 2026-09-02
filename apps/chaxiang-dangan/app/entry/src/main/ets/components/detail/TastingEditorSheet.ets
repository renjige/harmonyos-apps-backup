import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { TeaItem, TastingRecord } from '../../models/TeaModels'
import { TeaNav } from '../../services/TeaNav'
import { TeaStore } from '../../services/TeaStore'
import { DateFormatUtil } from '../design-system/DateFormatUtil'

@Component
export struct TastingEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop teaId: string = ''
  @Prop tastingId: string = ''
  @State selectedTeaId: string = ''
  @State dateKey: string = ''
  @State period: string = '下午'
  @State mood: string = '悠闲'
  @State aromaFeel: string = ''
  @State tasteFeel: string = ''
  @State note: string = ''
  @State scoreAroma: number = 4
  @State scoreTaste: number = 4
  @State scoreLove: number = 4
  @State scoreKeep: number = 3
  @State err: string = ''
  @State teas: TeaItem[] = []
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    this.teas = TeaStore.teas()
    this.selectedTeaId = this.teaId
    this.dateKey = DateFormatUtil.formatDate(new Date())
    if (this.tastingId.length === 0) {
      return
    }
    const rec = TeaStore.findTasting(this.tastingId)
    if (rec === null) {
      return
    }
    this.selectedTeaId = rec.teaId
    this.dateKey = rec.dateKey
    this.period = rec.period
    this.mood = rec.mood
    this.aromaFeel = rec.aromaFeel
    this.tasteFeel = rec.tasteFeel
    this.note = rec.note
    this.scoreAroma = rec.scoreAroma
    this.scoreTaste = rec.scoreTaste
    this.scoreLove = rec.scoreLove
    this.scoreKeep = rec.scoreKeep
  }

  private async save(): Promise<void> {
    if (this.selectedTeaId.length === 0) {
      this.err = '请先选择一款茶，或先去茶库建档'
      return
    }
    let rec = new TastingRecord()
    if (this.tastingId.length > 0) {
      const found = TeaStore.findTasting(this.tastingId)
      if (found !== null) {
        rec = found
      }
    }
    if (rec.id.length === 0) {
      rec.id = TeaStore.newId('sip_')
    }
    rec.teaId = this.selectedTeaId
    rec.dateKey = this.dateKey
    rec.period = this.period
    rec.mood = this.mood
    rec.aromaFeel = this.aromaFeel.trim()
    rec.tasteFeel = this.tasteFeel.trim()
    rec.note = this.note.trim()
    rec.scoreAroma = this.scoreAroma
    rec.scoreTaste = this.scoreTaste
    rec.scoreLove = this.scoreLove
    rec.scoreKeep = this.scoreKeep
    await TeaStore.saveTasting(rec)
    this.onSaved()
    TeaNav.closeTastingEditor()
    TeaNav.openTasting(rec.id)
  }

  private setPeriod(v: string): void {
    this.period = v
  }

  private setMood(v: string): void {
    this.mood = v
  }

  private setAroma(n: number): void {
    this.scoreAroma = n
  }

  private setTaste(n: number): void {
    this.scoreTaste = n
  }

  private setLove(n: number): void {
    this.scoreLove = n
  }

  private setKeep(n: number): void {
    this.scoreKeep = n
  }

  @Builder
  periodChip(label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.period === label ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.period === label ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .margin({ right: 8, bottom: 8 })
      .onClick((): void => { this.setPeriod(label) })
  }

  @Builder
  moodChip(label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.mood === label ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.mood === label ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .margin({ right: 8, bottom: 8 })
      .onClick((): void => { this.setMood(label) })
  }

  @Builder
  aromaDot(n: number) {
    Text(`${n}`)
      .fontSize(12)
      .fontColor(this.scoreAroma >= n ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .width(32)
      .height(32)
      .textAlign(TextAlign.Center)
      .borderRadius(16)
      .backgroundColor(this.scoreAroma >= n ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .onClick((): void => { this.setAroma(n) })
  }

  @Builder
  tasteDot(n: number) {
    Text(`${n}`)
      .fontSize(12)
      .fontColor(this.scoreTaste >= n ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .width(32)
      .height(32)
      .textAlign(TextAlign.Center)
      .borderRadius(16)
      .backgroundColor(this.scoreTaste >= n ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .onClick((): void => { this.setTaste(n) })
  }

  @Builder
  loveDot(n: number) {
    Text(`${n}`)
      .fontSize(12)
      .fontColor(this.scoreLove >= n ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .width(32)
      .height(32)
      .textAlign(TextAlign.Center)
      .borderRadius(16)
      .backgroundColor(this.scoreLove >= n ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .onClick((): void => { this.setLove(n) })
  }

  @Builder
  keepDot(n: number) {
    Text(`${n}`)
      .fontSize(12)
      .fontColor(this.scoreKeep >= n ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .width(32)
      .height(32)
      .textAlign(TextAlign.Center)
      .borderRadius(16)
      .backgroundColor(this.scoreKeep >= n ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .onClick((): void => { this.setKeep(n) })
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text(this.tastingId.length > 0 ? '编辑品饮' : '记录品饮')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { TeaNav.closeTastingEditor() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.teaId.length === 0) {
            Text('选择茶品')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            if (this.teas.length === 0) {
              Text('还没有茶档案。请先新增一款茶。')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
            }
            ForEach(this.teas, (t: TeaItem) => {
              Text(t.name)
                .fontSize(Theme.type.body)
                .fontColor(this.selectedTeaId === t.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding(10)
                .width('100%')
                .backgroundColor(this.selectedTeaId === t.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { this.selectedTeaId = t.id })
            }, (t: TeaItem) => t.id)
          }
          AppDatePickerField({
            label: '品饮日期',
            value: this.dateKey,
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string): void => { this.dateKey = v }
          })
          Flex({ wrap: FlexWrap.Wrap }) {
            this.periodChip('早晨')
            this.periodChip('下午')
            this.periodChip('晚上')
            this.periodChip('夜茶')
          }
          .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            this.moodChip('悠闲')
            this.moodChip('专注')
            this.moodChip('会客')
            this.moodChip('旅途')
          }
          .width('100%')
          TextInput({ text: this.aromaFeel, placeholder: '香气感受' }).onChange((v: string) => { this.aromaFeel = v })
          TextInput({ text: this.tasteFeel, placeholder: '口感感受' }).onChange((v: string) => { this.tasteFeel = v })
          TextArea({ text: this.note, placeholder: '备注，例如今天第一次尝试' })
            .height(72)
            .onChange((v: string) => { this.note = v })

          Row({ space: 8 }) {
            Text('香气').width(48).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary)
            this.aromaDot(1)
            this.aromaDot(2)
            this.aromaDot(3)
            this.aromaDot(4)
            this.aromaDot(5)
          }.width('100%')
          Row({ space: 8 }) {
            Text('口感').width(48).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary)
            this.tasteDot(1)
            this.tasteDot(2)
            this.tasteDot(3)
            this.tasteDot(4)
            this.tasteDot(5)
          }.width('100%')
          Row({ space: 8 }) {
            Text('喜爱').width(48).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary)
            this.loveDot(1)
            this.loveDot(2)
            this.loveDot(3)
            this.loveDot(4)
            this.loveDot(5)
          }.width('100%')
          Row({ space: 8 }) {
            Text('收藏').width(48).fontSize(Theme.type.bodyS).fontColor(Theme.colors().textSecondary)
            this.keepDot(1)
            this.keepDot(2)
            this.keepDot(3)
            this.keepDot(4)
            this.keepDot(5)
          }.width('100%')
          if (this.err.length > 0) {
            Text(this.err).fontSize(Theme.type.bodyS).fontColor(Theme.colors().danger)
          }
          AppButton({ label: '保存品饮', variant: 'primary', onTap: (): void => { void this.save() } })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
