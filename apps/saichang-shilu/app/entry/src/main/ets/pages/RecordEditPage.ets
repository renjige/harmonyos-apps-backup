import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { SportRecord, SportTypeOption } from '../models/SportRecord'
import { ResultOption } from '../models/SportExtra'
import { NamedChip, TagLib, WatchStatus } from '../models/CollectModels'
import { RecordStore } from '../services/RecordStore'

@Component
export struct RecordEditPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editMode: boolean = false
  @Prop seedId: string = ''
  @State record: SportRecord = SportRecord.createNew()
  @State toastText: string = ''
  onClose: () => void = () => {}
  onSaved: (saved: SportRecord) => void = (_saved: SportRecord): void => {}
  private sportOptions: SportTypeOption[] = SportTypeOption.all()
  private resultOptions: ResultOption[] = ResultOption.all()
  private statusChips: NamedChip[] = WatchStatus.all()
  private tags: string[] = TagLib.preset()
  private ratings: number[] = [1, 2, 3, 4, 5]

  aboutToAppear(): void {
    if (this.editMode && this.seedId.length > 0) {
      void RecordStore.findById(this.seedId).then((found): void => {
        if (found !== undefined) {
          this.record = found
        }
      })
    } else if (!this.editMode) {
      this.record = SportRecord.createNew()
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private applyTemplate(): void {
    if (this.record.title.length === 0) {
      this.record.title = '周末联赛'
    }
    if (this.record.note.length === 0) {
      this.record.note = '对阵：\n结果：\n精彩瞬间：\n我的评价：'
    }
    this.showToast('已套用观赛记录模板，按提示补全即可')
  }

  private toggleTag(tag: string): void {
    const parts = this.record.tagsPacked.split(',')
    const next: string[] = []
    let found = false
    for (const t of parts) {
      if (t.length === 0) {
        continue
      }
      if (t === tag) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(tag)
    }
    this.record.tagsPacked = next.join(',')
  }

  private async save(): Promise<void> {
    if (this.record.title.trim().length === 0) {
      this.showToast('请填写赛事名称')
      return
    }
    if (this.record.date.length === 0) {
      this.showToast('请选择日期')
      return
    }
    await RecordStore.saveRecord(this.record)
    const saved = SportRecord.cloneFrom(this.record)
    this.showToast('✓ 记录已保存')
    this.onSaved(saved)
    setTimeout((): void => { this.onClose() }, 400)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text(this.editMode ? '编辑赛事档案' : '记录赛事')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('套用观赛记录模板')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.applyTemplate() })

            this.FieldLabel('观赛清单')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.statusChips, (chip: NamedChip) => {
                Text(chip.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.record.status === chip.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.record.status === chip.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => {
                    const next = SportRecord.cloneFrom(this.record)
                    next.status = chip.id
                    this.record = next
                  })
              }, (chip: NamedChip) => chip.id)
            }
            .width('100%')

            this.FieldLabel('运动类型')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.sportOptions, (opt: SportTypeOption) => {
                Text(`${opt.emoji} ${opt.label}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.record.sportType === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.record.sportType === opt.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.record.sportType = opt.id })
              }, (opt: SportTypeOption) => opt.id)
            }
            .width('100%')

            this.FieldLabel('本场结果')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.resultOptions, (opt: ResultOption) => {
                Text(opt.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.record.result === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.record.result === opt.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.record.result = opt.id })
              }, (opt: ResultOption) => opt.id)
            }
            .width('100%')

            this.FieldLabel('赛事名称')
            TextInput({ text: this.record.title, placeholder: '例如：周末友谊赛' })
              .onChange((v: string) => { this.record.title = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)

            AppDatePickerField({
              label: '比赛日期',
              value: this.record.date,
              onChange: (v: string): void => { this.record.date = v }
            })

            this.FieldLabel('赛季')
            TextInput({ text: this.record.season, placeholder: '2026' })
              .onChange((v: string) => { this.record.season = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)

            this.FieldLabel('地点备注')
            TextInput({ text: this.record.location, placeholder: '场馆或城市，纯文字' })
              .onChange((v: string) => { this.record.location = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)

            this.FieldLabel('主队 / 己方')
            TextInput({ text: this.record.homeTeam, placeholder: '参赛队伍' })
              .onChange((v: string) => { this.record.homeTeam = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)

            this.FieldLabel('对手')
            TextInput({ text: this.record.opponent, placeholder: '对阵队伍' })
              .onChange((v: string) => { this.record.opponent = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)

            this.FieldLabel('比分 / 成绩')
            TextInput({ text: this.record.score, placeholder: '可选' })
              .onChange((v: string) => { this.record.score = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)

            this.FieldLabel('个人评价（星级）')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.ratings, (n: number) => {
                Text(`${n} 星`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.record.rating === n ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.record.rating === n ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.record.rating = n })
              }, (n: number) => `${n}`)
            }
            .width('100%')

            this.FieldLabel('多维评价（1–5 分）')
            Text('比赛质量')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.ratings, (n: number) => {
                Text(`${n}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.record.rateQuality === n ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.record.rateQuality === n ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.record.rateQuality = n })
              }, (n: number) => `q${n}`)
            }
            .width('100%')
            Text('对抗强度')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.ratings, (n: number) => {
                Text(`${n}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.record.rateIntensity === n ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.record.rateIntensity === n ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.record.rateIntensity = n })
              }, (n: number) => `i${n}`)
            }
            .width('100%')
            Text('现场氛围')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.ratings, (n: number) => {
                Text(`${n}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.record.rateAtmosphere === n ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.record.rateAtmosphere === n ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.record.rateAtmosphere = n })
              }, (n: number) => `a${n}`)
            }
            .width('100%')

            this.FieldLabel('观赛计划（赛前）')
            TextArea({ text: this.record.watchPlan, placeholder: '想关注的球员、战术、看点…' })
              .height(88)
              .onChange((v: string) => { this.record.watchPlan = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)

            this.FieldLabel('标签')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tags, (t: string) => {
                Text(t)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.record.tagsPacked.indexOf(t) >= 0 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.record.tagsPacked.indexOf(t) >= 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 6, bottom: 6 })
                  .onClick((): void => { this.toggleTag(t) })
              }, (t: string) => t)
            }
            .width('100%')

            this.FieldLabel('个人评价 / 备注')
            TextArea({ text: this.record.note, placeholder: '比赛过程、转折、观点…' })
              .height(120)
              .onChange((v: string) => { this.record.note = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: 100 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)

        Column() {
          AppButton({
            label: '保存赛事档案',
            variant: 'primary',
            onTap: (): void => { void this.save() }
          })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s4, top: Theme.space.s2 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(60)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }

  @Builder
  FieldLabel(text: string) {
    Text(text).fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
  }
}
