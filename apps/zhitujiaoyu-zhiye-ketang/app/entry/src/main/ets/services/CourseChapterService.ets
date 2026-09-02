import { CourseChapterItem, CourseItem } from '../models/CareerModels'

/**
 * 按课程生成章节内容与类型（首章视频演示，其余图文）。
 */
export class CourseChapterService {
  static buildChapters(course: CourseItem): CourseChapterItem[] {
    const titles: string[] = [
      '课程导学与环境准备',
      '核心概念与方法论',
      '案例拆解与场景演练',
      '工具模板与实操练习',
      '常见问题与避坑指南',
      '综合复盘与延伸学习'
    ]
    let count = 6
    if (course.duration.indexOf('10') >= 0 || course.duration.indexOf('12') >= 0) {
      count = 8
      titles.push('进阶专题一')
      titles.push('进阶专题二')
    } else if (course.duration.indexOf('8') >= 0 || course.duration.indexOf('9') >= 0) {
      count = 7
      titles.push('进阶专题')
    }
    const out: CourseChapterItem[] = []
    let i = 0
    while (i < count && i < titles.length) {
      const ch = new CourseChapterItem()
      ch.index = i + 1
      ch.title = titles[i]
      ch.kind = i === 0 ? 'video' : 'text'
      ch.durationMin = i === 0 ? 12 : 8 + (i % 3)
      ch.body = CourseChapterService.bodyFor(course, ch.title, ch.kind)
      out.push(ch)
      i = i + 1
    }
    return out
  }

  private static bodyFor(course: CourseItem, chapterTitle: string, kind: string): string {
    const intro = `【${course.title} · ${chapterTitle}】\n\n`
    if (kind === 'video') {
      return intro +
        '本章为视频精讲演示（上架包不含外链视频，以封面与要点摘要呈现）。\n\n' +
        `学习目标：理解「${course.category}」在本课程中的核心框架。\n\n` +
        `要点摘要：${course.summary}\n\n` +
        '建议：完整观看后点击「标记本章完成」，系统将记录学习进度与本周学习日历。'
    }
    return intro +
      `围绕「${course.category}」方向，本章深入讲解${chapterTitle}。\n\n` +
      `${course.description.length > 80 ? course.description.substring(0, 200) + '…' : course.description}\n\n` +
      '练习建议：结合本章节内容，在真实工作场景中尝试 1 个小动作，并在下一章继续深化。'
  }
}
