import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { SportRecord, SportTypeOption } from '../models/SportRecord'
import { CompareField, ResultOption } from '../models/SportExtra'
import { RecordStore } from '../services/RecordStore'
import { SportRecordDetailPane } from '../components/sport/SportRecordDetailPane'

@Component
export struct MatchComparePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State all: SportRecord[] = []
  @State leftId: string = ''
  @State rightId: string = ''
  @State fields: CompareField[] = []
  @State detail: SportRecord | undefined = undefined
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void RecordStore.loadAll().then((list): void => {
      this.all = list
      if (list.length > 0) {
        this.leftId = list[0].id
      }
      if (list.length > 1) {
        this.rightId = list[1].id
      }
      this.rebuild()
    })
  }

  private find(id: string): SportRecord | undefined {
    for (const it of this.all) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  private rebuild(): void {
    const left = this.find(this.leftId)
    const right = this.find(this.rightId)
    if (left === undefined || right === undefined) {
      this.fields = []
      return
    }
    const rows: CompareField[] = []
    rows.push(this.row('日期', left.date, right.date))
    rows.push(this.row('运动', SportTypeOption.labelOf(left.sportType), SportTypeOption.labelOf(right.sportType)))
    rows.push(this.row('评价', left.rating > 0 ? `${left.rating} 星` : '—', right.rating > 0 ? `${right.rating} 星` : '—'))
    rows.push(this.row('结果', ResultOption.labelOf(left.result), ResultOption.labelOf(right.result)))
    rows.push(this.row('时长', left.duration > 0 ? `${left.duration} 分` : '—', right.duration > 0 ? `${right.duration} 分` : '—'))
    rows.push(this.row('复盘', left.recapScore.length > 0 ? left.recapScore : '—', right.recapScore.length > 0 ? right.recapScore : '—'))
    rows.push(this.row('MVP', left.mvpName.length > 0 ? left.mvpName : '—', right.mvpName.length > 0 ? right.mvpName : '—'))
    rows.push(this.row('标签', left.tagsPacked.replace(/,/g, ' · '), right.tagsPacked.replace(/,/g, ' · ')))
    this.fields = rows
  }

  private row(label: string, left: string, right: string): CompareField {
    const f = new CompareField()
    f.label = label
    f.left = left.length > 0 ? left : '—'
    f.right = right.length > 0 ? right : '—'
    return f
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
          Text('比赛对比')
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
            if (this.all.length < 2) {
              Text('至少需要 2 场赛事记录才能对比。先去记一场吧。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            } else {
              Text('选择两场赛事，对照日期、结果、评价与复盘得分。')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

              Column({ space: Theme.space.s2 }) {
                Text('场次 A')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                ForEach(this.all, (m: SportRecord) => {
                  Text(m.title.length > 0 ? `${m.title} · ${m.date}` : m.date)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.leftId === m.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .width('100%')
                    .padding(Theme.space.s3)
                    .backgroundColor(this.leftId === m.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.md)
                    .onClick((): void => { this.leftId = m.id; this.rebuild() })
                }, (m: SportRecord) => `l-${m.id}`)
              }
              .width('100%')

              Column({ space: Theme.space.s2 }) {
                Text('场次 B')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                ForEach(this.all, (m: SportRecord) => {
                  Text(m.title.length > 0 ? `${m.title} · ${m.date}` : m.date)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.rightId === m.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .width('100%')
                    .padding(Theme.space.s3)
                    .backgroundColor(this.rightId === m.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.md)
                    .onClick((): void => { this.rightId = m.id; this.rebuild() })
                }, (m: SportRecord) => `r-${m.id}`)
              }
              .width('100%')

              Column({ space: Theme.space.s2 }) {
                Row() {
                  Text('对比项')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('28%')
                  Text('A')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .layoutWeight(1)
                  Text('B')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .layoutWeight(1)
                }
                .width('100%')
                ForEach(this.fields, (f: CompareField) => {
                  Row({ space: 4 }) {
                    Text(f.label)
                      .fontSize(Theme.type.bodyS)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('28%')
                    Text(f.left)
                      .fontSize(Theme.type.bodyS)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .layoutWeight(1)
                    Text(f.right)
                      .fontSize(Theme.type.bodyS)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .layoutWeight(1)
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.md)
                }, (f: CompareField) => f.label)
              }
              .width('100%')

              Row({ space: Theme.space.s3 }) {
                AppButton({
                  label: '查看 A 详情',
                  variant: 'secondary',
                  onTap: (): void => { this.detail = this.find(this.leftId) }
                })
                AppButton({
                  label: '查看 B 详情',
                  variant: 'secondary',
                  onTap: (): void => { this.detail = this.find(this.rightId) }
                })
              }
              .width('100%')
            }
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.detail !== undefined) {
        SportRecordDetailPane({
          record: this.detail,
          onClose: (): void => { this.detail = undefined },
          onDeleted: (): void => { this.detail = undefined; void this.aboutToAppear() },
          onEdit: (): void => { this.detail = undefined },
          onRecap: (): void => { this.detail = undefined },
          onTimeline: (): void => { this.detail = undefined },
          onWorkbench: (): void => { this.detail = undefined }
        })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(70)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
