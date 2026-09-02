/**
 * Industry-specific core page shell.
 */
import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { AppButton } from '../components/design-system/AppButton'
import { AuthService } from '../services/AuthService'

class BizItem {
  title: string = ''
  status: string = ''

  static draft(): BizItem {
    const item = new BizItem()
    item.title = '新建业务单'
    item.status = '草稿'
    return item
  }

  static seed(): BizItem[] {
    const a = new BizItem()
    a.title = '客户回访 — 包头某制造厂'
    a.status = '跟进中'
    const b = new BizItem()
    b.title = '合同审批 — Q3 服务续约'
    b.status = '待审批'
    const c = new BizItem()
    c.title = '项目交付 — 智企系统上线'
    c.status = '进行中'
    return [a, b, c]
  }
}

@Component
export struct CoreBizPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop pageTitle: string = '智企协同'
  @State items: BizItem[] = []
  onRequireAuth: () => void = () => {}

  aboutToAppear() {
    if (this.items.length === 0) {
      this.items = BizItem.seed()
    }
  }

  private addDraft(): void {
    if (!AuthService.requireAuth('create')) {
      this.onRequireAuth()
      return
    }
    const draft = BizItem.draft()
    const next: BizItem[] = [draft]
    for (let item of this.items) {
      next.push(item)
    }
    this.items = next
  }

  build() {
    Column() {
      AppHeader({ title: this.pageTitle, subtitle: '客户 · 任务工单 · 协同跟进' })
      Row() {
        AppButton({
          label: '新建',
          onTap: () => this.addDraft()
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '暂无业务数据',
          description: '创建第一条记录开始闭环',
          actionLabel: '新建',
          onAction: () => this.addDraft()
        })
      } else {
        List() {
          ForEach(this.items, (it: BizItem, idx: number) => {
            ListItem() {
              AppCard({ title: it.title }) {
                Text(it.status)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (it: BizItem, idx: number) => `biz-${idx}`)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
