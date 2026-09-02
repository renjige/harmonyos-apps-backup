import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { ExploreRecord } from '../../models/ExploreRecordModels'
import { ExploreRecordStore } from '../../services/ExploreRecordStore'
import { NqDetailNav } from '../../services/NqDetailNav'

class WeatherOption {
  label: string = ''

  constructor(label: string) {
    this.label = label
  }
}

@Component
export struct RecordEditorOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onEditorChange') editId: string = ''
  @Prop @Watch('onEditorChange') refreshToken: number = 0
  @State title: string = ''
  @State location: string = ''
  @State date: string = ''
  @State weather: string = '晴'
  @State body: string = ''
  @State latText: string = ''
  @State lngText: string = ''
  @State toastText: string = ''
  @State saving: boolean = false
  private recordId: string = ''
  private weatherOptions: WeatherOption[] = [
    new WeatherOption('晴'),
    new WeatherOption('阴'),
    new WeatherOption('雨'),
    new WeatherOption('雪'),
    new WeatherOption('雾')
  ]

  aboutToAppear(): void {
    void this.loadRecord()
  }

  onEditorChange(): void {
    void this.loadRecord()
  }

  private async loadRecord(): Promise<void> {
    if (this.editId.length > 0) {
      const existing = await ExploreRecordStore.findById(this.editId)
      if (existing !== undefined) {
        this.recordId = existing.id
        this.title = existing.title
        this.location = existing.location
        this.date = existing.date
        this.weather = existing.weather.length > 0 ? existing.weather : '晴'
        this.body = existing.body
        this.latText = existing.lat !== 0 ? `${existing.lat}` : ''
        this.lngText = existing.lng !== 0 ? `${existing.lng}` : ''
        return
      }
    }
    const rec = ExploreRecord.createNew()
    this.recordId = rec.id
    this.title = ''
    this.location = ''
    this.date = rec.date
    this.weather = '晴'
    this.body = ''
    this.latText = ''
    this.lngText = ''
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写标题')
      return
    }
    this.saving = true
    const rec = new ExploreRecord()
    rec.id = this.recordId
    rec.title = this.title.trim()
    rec.location = this.location.trim()
    rec.date = this.date
    rec.weather = this.weather
    rec.body = this.body.trim()
    rec.lat = this.latText.length > 0 ? parseFloat(this.latText) : 0
    rec.lng = this.lngText.length > 0 ? parseFloat(this.lngText) : 0
    const existing = await ExploreRecordStore.findById(this.recordId)
    rec.createdAt = existing !== undefined ? existing.createdAt : Date.now()
    const ok = await ExploreRecordStore.save(rec)
    this.saving = false
    if (ok) {
      NqDetailNav.openRecord(rec.id)
      return
    }
    this.showToast('保存失败，请重试')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick(() => NqDetailNav.close())
          Text(this.editId.length > 0 ? '编辑探索记录' : '新建探索记录')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 12, right: Theme.space.pageX, top: 8 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('标题')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.title, placeholder: '给这次探索起个名字' })
              .onChange((v: string) => { this.title = v })
              .width('100%')

            Text('地点')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.location, placeholder: '森林、山脊或公园名称' })
              .onChange((v: string) => { this.location = v })
              .width('100%')

            AppDatePickerField({
              label: '日期',
              value: this.date,
              minDaysFromToday: -3650,
              maxDaysFromToday: 0,
              onChange: (v: string): void => { this.date = v }
            })

            Text('天气')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.weatherOptions, (w: WeatherOption) => {
                  Text(w.label)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.weather === w.label ?
                      Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(this.weather === w.label ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.weather = w.label })
                }, (w: WeatherOption) => w.label)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            Text('正文')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.body, placeholder: '记录所见所闻、动植物与心情…' })
              .height(120)
              .onChange((v: string) => { this.body = v })
              .width('100%')

            Row({ space: Theme.space.s3 }) {
              Column({ space: 4 }) {
                Text('纬度（可选）')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                TextInput({ text: this.latText, placeholder: '0.0' })
                  .onChange((v: string) => { this.latText = v })
              }
              .layoutWeight(1)
              Column({ space: 4 }) {
                Text('经度（可选）')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                TextInput({ text: this.lngText, placeholder: '0.0' })
                  .onChange((v: string) => { this.lngText = v })
              }
              .layoutWeight(1)
            }
            .width('100%')

            AppButton({
              label: this.saving ? '保存中…' : '保存记录',
              disabled: this.saving,
              onTap: (): void => { void this.save() }
            })
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
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
