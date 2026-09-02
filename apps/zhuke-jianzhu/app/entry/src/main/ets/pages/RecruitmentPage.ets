import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppListRow } from '../components/design-system/AppListRow'
import { ContentService } from '../services/ContentService'
import { JobItem } from '../models/ZhukeModels'
import { AppEmpty } from '../components/design-system/AppEmpty'

@Component
export struct RecruitmentPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State jobs: JobItem[] = []
  onBack: () => void = () => {}
  onOpenDetail: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    this.jobs = ContentService.jobs()
  }

  build() {
    Column() {
      AppNavBar({ title: '人才招聘', onBack: () => this.onBack() })

      if (this.jobs.length === 0) {
        AppEmpty({ title: '暂无招聘岗位', description: '请关注后续招聘公告' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('筑科建筑诚聘英才，共建品质工程')
              .fontSize(Theme.type.callout)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .padding({ bottom: Theme.space.s2 })

            ForEach(this.jobs, (j: JobItem, index: number) => {
              Column() {
                AppListRow({
                  title: j.title,
                  subtitle: `${j.department} · ${j.location} · ${j.salary}`,
                  showDivider: index < this.jobs.length - 1,
                  onTap: () => this.onOpenDetail(j.id)
                })
              }
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding({ left: Theme.space.s3, right: Theme.space.s3 })
            }, (j: JobItem) => j.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s8
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
